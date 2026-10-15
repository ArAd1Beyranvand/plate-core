"""Builds the few-shot Ollama model `plate-regions` from hand-labelled sections
of 5 Wikipedia pages, and scores it.

    python3 train.py            # write Modelfile, ollama create, then evaluate
    python3 train.py --eval     # evaluate only

There is no weight training: the labelled HTML chunks become MESSAGE
user/assistant pairs in the Modelfile, which Ollama prepends to every
request. Ollama reuses the KV cache for that fixed prefix, so only the first
call pays for it.

Positive = the section says which plate letters/digits identify which state,
province, district or city: as a rule in prose, a list, or a table, any era.
Government/diplomatic/military/colour/serial-number sections are negative.
Sections left out of a country's lists were judged ambiguous.
"""
import json
import subprocess
import sys
import time

import regions
import scanner_gui

BASE = 'qwen3.5:0.8b'
# What each example shows the model; shorter than regions.MODEL_CHARS so 24
# examples fit, still long enough to show the table header and first rows.
EXAMPLE_CHARS = 900

LABELS = {
    'India': {
        'yes': ['Private_and_commercial_vehicles', 'Part_1:_Two-letter_state_code', 'Current_codes', 'Former_codes',
                'Part_2:_RTO_number', 'Pre-1940', 'From_1940_till_1989', 'French_and_Portuguese_colonies'],
        'no': ['_intro', 'Colour_coding', 'VA_(Vintage)_series', 'BH_(Bharat)_series', 'Vehicles_of_Indian_Armed_Forces',
               'Vehicles_of_diplomatic_missions', 'Part_3:_Single_or_multiple_letters',
               'Part_4:_Unique_number_between_1_and_9999', 'Temporary_registration_format',
               'Trade_registration_format', 'HSRP:_High_security_registration_plate', 'Historical_colour_coding',
               'Top_constitutional_authorities', 'Pre-2022_trade_registration'],
    },
    'Spain': {
        'yes': ['1900_to_1970', '1970_to_2000', 'Provincial_codes'],
        'no': ['_intro', 'Current_system', 'Commercial_Vehicles', 'State_codes', 'Diplomatic_plates', 'U.S._military',
               'Colour_plates', 'Diplomatic_codes'],
    },
    'Kazakhstan': {
        'yes': ['_intro', 'Design_until_August_2012', 'Regional_codes', 'Codes_on_Soviet_era_plates'],
        'no': ['Codes_on_government_plates', 'Codes_on_diplomatic_plates'],
    },
    'Malaysia': {
        'yes': ['Current_format', 'Current_format_2', 'Current_format_3', 'Pre-1948', 'Post-1948', 'Pre-1991',
                'Post-1991', 'Pre-1980s', 'Post-1980s', 'Taxi'],
        'no': ['_intro', 'Design', 'Diplomatic_Corps', 'Consular_Corps', 'United_Nations',
               'Other_international_organisations', 'Military', 'Royalty', 'Trade_plates', 'Trailer_plates',
               'Commemorative_plates', 'To_and_from_Singapore', 'To_and_from_Thailand'],
    },
    'Germany': {
        'yes': ['Area_code', 'Development_of_the_area_code', 'The_Büsingen_exclave', 'List_of_area_codes',
                'German_Empire_and_Weimar_Republic', 'Postwar_Germany', 'East_Germany,_DDR', 'West_Germany',
                'Germany_reunited'],
        'no': ['_intro', 'Legal', 'Physical_characteristics', 'Typeface', 'Material', 'Stickers',
               'Serial_letters_and_digits', 'Personalised_plates', 'Company_cars', 'Prohibited_combinations',
               'Reserved_combinations', 'Fictitious_licence_plates', 'Procedures', 'Costs', 'Federal_government',
               'Diplomatic_plates', 'Military', 'Green_on_white', 'H_for_historic', 'E_for_electric', 'Seasonal',
               'Temporary_registration', 'Export', 'Insurance_plates', 'Examples'],
    },
}

# Subset shown to the model: each shape of positive (prose rule, list, table,
# historical) and the negatives most easily confused with them.
EXAMPLES = [
    ('India', 'Private_and_commercial_vehicles'), ('India', 'Current_codes'), ('India', 'Part_2:_RTO_number'),
    ('India', 'Vehicles_of_diplomatic_missions'), ('India', 'Part_3:_Single_or_multiple_letters'),
    ('India', 'Colour_coding'),
    ('Spain', 'Provincial_codes'), ('Spain', '1970_to_2000'), ('Spain', 'State_codes'), ('Spain', 'Current_system'),
    ('Kazakhstan', 'Regional_codes'), ('Kazakhstan', 'Codes_on_Soviet_era_plates'),
    ('Kazakhstan', 'Codes_on_government_plates'), ('Kazakhstan', 'Codes_on_diplomatic_plates'),
    ('Malaysia', 'Current_format_2'), ('Malaysia', 'Pre-1948'), ('Malaysia', 'Diplomatic_Corps'),
    ('Malaysia', 'Commemorative_plates'),
    ('Germany', 'Area_code'), ('Germany', 'List_of_area_codes'), ('Germany', 'Federal_government'),
    ('Germany', 'Serial_letters_and_digits'), ('Germany', 'Physical_characteristics'), ('Germany', '_intro'),
]

# Never shown to the model; labelled the same way, for an honest score.
HELD_OUT = {
    'Norway': {
        'yes': ['Prefixes_and_sequence_numbers', 'Registration_letter_codes_1913–1971'],
        'no': ['_intro', 'A_–_White_reflective_plate,_black_print', 'D_–_Orange_plates,_black_print',
               'F_–_Blue_plate,_yellow_print', 'G_–_Red_plate,_white_print', 'Personalised_number_plates',
               'Validation_sticker', 'Nationality_stripe', 'Manufacture_of_licence_plates', 'Diplomatic_Corps_codes',
               'Other_issues'],
    },
    'Italy': {
        'yes': ['Province_codes_1927_to_present_day', 'Province_codes_1905_to_1927',
                'Defunct_province_codes_(post-1927)', 'Former_provincial_code_system_(1927–1994)'],
        'no': ['Rectangular_plates', 'Squared_plates', 'Diplomatic_plates', 'Military_plates', 'Red_Cross_plates',
               'Firefighters', 'Carabinieri_plates', 'Port_Authority_plates', 'Temporary_plates', 'Diplomatic_codes'],
    },
    'Iran': {
        'yes': ['Private_vehicles', 'Provincial_codes_and_letter_series', 'Provincial_codes',
                'Provincial_codes_10_to_19', 'Provincial_codes_50_to_59', 'Provincial_codes_90_to_99'],
        'no': ['Letter_series', 'Numbers', 'Government_vehicles', 'Police_(FARAJA)_vehicles', 'Army_Police',
               'Ministry_of_Defence', 'Historic_Vehicles', 'Political_and_services_plates', 'Temporary_passage'],
    },
    'Kyrgyzstan': {
        'yes': ['2015', 'Private_vehicles', 'Current', '1994-2016', '1980-1994'],
        'no': ['Foreign', 'Diplomatic'],
    },
}

SYSTEM = """You read one section of a Wikipedia article about a country's vehicle registration plates, given as HTML.
Decide if the section tells which letters or digits on a plate identify a geographic region:
a state, province, region, district, county, city, division, governorate, prefecture, department,
municipality, oblast, krai, canton, voivodeship, wilaya, emirate, territory, zone, island, atoll,
parish, commune, arrondissement, borough, town or the local registration office (e.g. an RTO). It counts as a prose rule
("the first two letters indicate the state"), a list, or a table of codes and places, current or historical.
It does NOT count if the section is only about colours, sizes, fonts, serial numbers, government,
military, diplomatic or organisation codes, or the plate history without codes per place.
Answer only JSON: {"region_codes": true} or {"region_codes": false}."""


def log(msg):
    print(msg, flush=True)


def page(country):
    url = 'https://en.wikipedia.org/wiki/Vehicle_registration_plates_of_' + country.replace(' ', '_')
    html, cached = scanner_gui.fetch(url)
    return html


def by_id(country):
    return {s['id']: s for s in regions.sections(page(country))}


def modelfile():
    lines = [f'FROM {BASE}', 'PARAMETER temperature 0', 'PARAMETER num_ctx 12288',
             f'SYSTEM """{SYSTEM}"""']
    for country, sid in EXAMPLES:
        s = by_id(country)[sid]
        answer = sid in LABELS[country]['yes']
        text = regions.model_input(country, s).replace('"""', "'''")
        cut = len(text) - len(regions.compact(s['html'])[:regions.MODEL_CHARS])  # header length
        text = text[:cut + EXAMPLE_CHARS]
        lines.append(f'MESSAGE user """{text}"""')
        lines.append(f'MESSAGE assistant {json.dumps({"region_codes": answer})}')
    return '\n'.join(lines) + '\n'


def evaluate(labels, title):
    right = total = 0
    for country, lab in labels.items():
        if not lab:
            continue
        secs = by_id(country)
        for want, ids in ((True, lab['yes']), (False, lab['no'])):
            for sid in ids:
                t0 = time.time()
                got = regions.classify(country, secs[sid])
                total += 1
                right += got == want
                log(f'  {"ok   " if got == want else "WRONG"} {time.time() - t0:5.1f}s  {country} / {sid}: '
                    f'said {got}, label {want}')
    log(f'== {title}: {right}/{total} correct')


if __name__ == '__main__':
    for c in list(LABELS) + list(HELD_OUT):
        log(f'page {c}: {len(regions.sections(page(c)))} sections')
    if '--eval' not in sys.argv:
        path = regions.HERE / 'Modelfile'
        text = modelfile()
        path.write_text(text, encoding='utf-8')
        log(f'wrote {path}: {len(EXAMPLES)} examples, {len(text)} chars (~{len(text) // 3} tokens of prefix)')
        log(f'ollama create {regions.MODEL} from {BASE}')
        subprocess.run(['ollama', 'create', regions.MODEL, '-f', str(path)], check=True)
        log('first request loads the model and evaluates the example prefix; it is slower than the rest')
    shown = set(EXAMPLES)
    unseen = {c: {k: [s for s in v if (c, s) not in shown] for k, v in lab.items()} for c, lab in LABELS.items()}
    evaluate(unseen, 'training pages, sections not used as examples')
    evaluate(HELD_OUT, 'held-out pages')
