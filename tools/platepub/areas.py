"""Countries / territories and their sub-areas, after
https://en.wikipedia.org/wiki/Vehicle_registration_plate; a name with no sub-areas maps to []."""
import re
import unicodedata

AREAS = {
    "Afghanistan": [], "Albania": [], "Algeria": [], "Andorra": [], "Angola": [],
    "Antigua and Barbuda": [], "Argentina": [], "Armenia": [],
    "Australia": ["Australian Capital Territory", "New South Wales", "Northern Territory",
                  "Queensland", "South Australia", "Tasmania", "Victoria", "Western Australia"],
    "Austria": [], "Azerbaijan": ["Nakhchivan"], "Bahamas": [], "Bahrain": [],
    "Bangladesh": [], "Barbados": [], "Belarus": [], "Belgium": [], "Belize": [],
    "Benin": [], "Bhutan": [], "Bolivia": [], "Bosnia and Herzegovina": [],
    "Botswana": [], "Brazil": [], "Brunei": [], "Bulgaria": [], "Burkina Faso": [],
    "Burundi": [], "Cambodia": [], "Cameroon": [],
    "Canada": ["Alberta", "British Columbia", "Manitoba", "New Brunswick",
               "Newfoundland and Labrador", "Northwest Territories", "Nova Scotia",
               "Nunavut", "Ontario", "Prince Edward Island", "Quebec", "Saskatchewan", "Yukon"],
    "Cape Verde": [], "Central African Republic": [], "Chad": [], "Chile": [],
    "China": ["Hong Kong", "Macau"], "Colombia": [], "Comoros": [],
    "Congo": [], "Costa Rica": [], "Croatia": [], "Cuba": [], "Cyprus": ["Northern Cyprus"],
    "Czech Republic": [], "Democratic Republic of the Congo": [], "Denmark": ["Faroe Islands", "Greenland"],
    "Djibouti": [], "Dominica": [], "Dominican Republic": [], "Ecuador": [], "Egypt": [],
    "El Salvador": [], "Equatorial Guinea": [], "Eritrea": [], "Estonia": [],
    "Eswatini": [], "Ethiopia": [], "Fiji": [], "Finland": ["Aland"],
    "France": ["French Guiana", "French Polynesia", "Guadeloupe", "Martinique",
               "Mayotte", "New Caledonia", "Reunion", "Saint Pierre and Miquelon",
               "Wallis and Futuna"],
    "Gabon": [], "Gambia": [], "Georgia": ["Abkhazia", "South Ossetia"],
    "Germany": [], "Ghana": [], "Greece": [], "Grenada": [], "Guatemala": [],
    "Guinea": [], "Guinea-Bissau": [], "Guyana": [], "Haiti": [], "Honduras": [],
    "Hungary": [], "Iceland": [],
    "India": ["Andaman and Nicobar Islands", "Andhra Pradesh", "Arunachal Pradesh", "Assam",
              "Bihar", "Chandigarh", "Chhattisgarh", "Delhi", "Goa", "Gujarat", "Haryana",
              "Himachal Pradesh", "Jammu and Kashmir", "Jharkhand", "Karnataka", "Kerala",
              "Ladakh", "Lakshadweep", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya",
              "Mizoram", "Nagaland", "Odisha", "Puducherry", "Punjab", "Rajasthan", "Sikkim",
              "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh", "Uttarakhand", "West Bengal"],
    "Indonesia": [], "Iran": [], "Iraq": [], "Ireland": [], "Israel": [], "Italy": [],
    "Ivory Coast": [], "Jamaica": [], "Japan": [], "Jordan": [], "Kazakhstan": [],
    "Kenya": [], "Kiribati": [], "Kosovo": [], "Kuwait": [], "Kyrgyzstan": [],
    "Laos": [], "Latvia": [], "Lebanon": [], "Lesotho": [], "Liberia": [], "Libya": [],
    "Liechtenstein": [], "Lithuania": [], "Luxembourg": [], "Madagascar": [],
    "Malawi": [], "Malaysia": [], "Maldives": [], "Mali": [], "Malta": [],
    "Marshall Islands": [], "Mauritania": [], "Mauritius": [], "Mexico": [],
    "Micronesia": [], "Moldova": ["Transnistria"], "Monaco": [], "Mongolia": [],
    "Montenegro": [], "Morocco": [], "Mozambique": [], "Myanmar": [], "Namibia": [],
    "Nauru": [], "Nepal": [],
    "Netherlands": ["Aruba", "Bonaire", "Curacao", "Saba", "Sint Eustatius", "Sint Maarten"],
    "New Zealand": ["Cook Islands", "Niue"], "Nicaragua": [], "Niger": [], "Nigeria": [],
    "North Korea": [], "North Macedonia": [], "Norway": ["Svalbard"], "Oman": [],
    "Pakistan": [], "Palau": [], "Palestine": [], "Panama": [], "Papua New Guinea": [],
    "Paraguay": [], "Peru": [], "Philippines": [], "Poland": [], "Portugal": [],
    "Qatar": [], "Romania": [], "Russia": [], "Rwanda": [], "Saint Kitts and Nevis": [],
    "Saint Lucia": [], "Saint Vincent and the Grenadines": [], "Samoa": [],
    "San Marino": [], "Sao Tome and Principe": [], "Saudi Arabia": [], "Senegal": [],
    "Serbia": [], "Seychelles": [], "Sierra Leone": [], "Singapore": [], "Slovakia": [],
    "Slovenia": [], "Solomon Islands": [], "Somalia": ["Somaliland"], "South Africa": [],
    "South Korea": [], "South Sudan": [], "Spain": [], "Sri Lanka": [], "Sudan": [],
    "Suriname": [], "Sweden": [], "Switzerland": [], "Syria": [], "Taiwan": [],
    "Tajikistan": [], "Tanzania": [], "Thailand": [], "Timor-Leste": [], "Togo": [],
    "Tonga": [], "Trinidad and Tobago": [], "Tunisia": [], "Turkey": [], "Turkmenistan": [],
    "Tuvalu": [], "Uganda": [], "Ukraine": [], "United Arab Emirates": [
        "Abu Dhabi", "Ajman", "Dubai", "Fujairah", "Ras Al Khaimah", "Sharjah", "Umm Al Quwain"],
    "United Kingdom": ["Anguilla", "Ascension Island", "Bermuda", "British Virgin Islands",
                       "Cayman Islands", "Falkland Islands", "Gibraltar", "Guernsey",
                       "Isle of Man", "Jersey", "Montserrat", "Saint Helena",
                       "Tristan da Cunha", "Turks and Caicos Islands"],
    "United States": ["American Samoa", "Guam", "Northern Mariana Islands", "Puerto Rico",
                      "US Virgin Islands"],
    "Uruguay": [], "Uzbekistan": [], "Vanuatu": [], "Vatican City": [], "Venezuela": [],
    "Vietnam": [], "Yemen": [], "Zambia": [], "Zimbabwe": [],
}


def slug(name):
    s = unicodedata.normalize("NFKD", name).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "_", s.lower()).strip("_")


# package slug -> (country, area or "")
LOOKUP = {}
for _c, _areas in AREAS.items():
    LOOKUP[slug(_c)] = (_c, "")
    for _a in _areas:
        LOOKUP.setdefault(slug(_a), (_c, _a))


def describe(pkg):
    base = pkg[:-6] if pkg.endswith("_plate") else pkg
    return LOOKUP.get(base) or (base.replace("_", " ").title(), "")
