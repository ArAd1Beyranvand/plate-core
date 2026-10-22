# Israel-code / diplomatic-plate report

Generated 2026-10-17. Sources: the cached Wikipedia articles in `.plateref/*/art.html` (navboxes stripped), `PlateRestriction` usage in each package, and the gallery notes. Nothing was fetched from the web for this report.

**Scope.** 105 package directories. `iranshahr_plate` bundles 14 country modules (Afghanistan, Armenia, Azerbaijan, Bahrain, Iraq, Kazakhstan, Kuwait, Oman, Qatar, Tajikistan, Turkey, Turkmenistan, UAE, Uzbekistan), so the country count is higher than the directory count.

**"Has an Israel code"** means the article's diplomatic code table lists Israel (a number or letters that identify the mission). It is not a statement about the real world.

## 1. Diplomatic plate, article lists an Israel code, banned (test these)
| Package | Refused value |
|---|---|
| `belarus` | mission 09 |
| `chile` | mission 39 |
| `norway` | embassy 44 |
| `philippines` | mission 036 |
| `serbia` | code 20 (note: the cached article's table shows `123 Israel`; worth a manual check) |
| `spain` | embassy 83 |
| `sweden` | mission CA |
| `switzerland` | code 7 |
| `ukraine` | code 012 |
| `vietnam` | 336–340 |
| `iranshahr_plate` / Kazakhstan | 007 |
| `iranshahr_plate` / Uzbekistan | 011 |

## 2. Had an Israel code but no ban: fixed in this change
| Package | Refused value | Change |
|---|---|---|
| `india_plate` | mission 109 | new `lib/src/india_missions.dart`, `restrictions` on `IndiaPlates.diplomatic`, test `test/mission_109_test.dart` (all 22 india tests pass) |

## 3. Article lists an Israel code, but no diplomatic plate is implemented (nothing to ban yet)
- `italy`: article table has `HL = Israel`. Diplomatic, consular and UN plates are now implemented and `HL` is refused (see the Italy note below). Moved to section 1 in effect.
- Not a package here: Russia (`127 Israel`).

## 4. Diplomatic plate implemented, no Israel code in the cached article (no ban needed)
`algeria`, `bhutan`, `bolivia`, `bosnia_and_herzegovina`, `brazil`, `brunei`, `cambodia`, `cameroon`, `cape_verde`, `colombia`, `egypt`, `finland`, `indonesia`, `iran`, `japan`, `jordan`, `kyrgyzstan`, `laos`, `libya`, `madagascar`, `malaysia`, `namibia`, `netherlands`, `nicaragua`, `niger`, `north_korea`, `portugal`, `san_marino`, `slovakia`, `slovenia`, `united_kingdom`, `uruguay`, `vanuatu`, `yemen`

`iranshahr_plate`: Turkmenistan; Turkey (diplomatic numbers are random since 2004, per the gallery note).

## 5. Previously unverified, now checked against Wikipedia (2026-10-17)
`lebanon`, `maldives`, and iranshahr's `afghanistan`, `armenia`, `azerbaijan`, `bahrain`, `kuwait`, `tajikistan`: none of the articles lists an Israel code, so no ban is needed. Azerbaijan's embassy plates use a country number (001 = Turkey, 013 = UN) but the article lists no table naming Israel.

## 6. Unclear whether a diplomatic plate is implemented (themes / white-field only)
`myanmar`, `thailand`, `tanzania`

## 7. No diplomatic plate implemented
`andorra`, `angola`, `antigua_and_barbuda`, `bahamas`, `barbados`, `belgium`, `belize`, `benin`, `botswana`, `burkina_faso`, `canada`, `central_african_republic`, `chad`, `comoros`, `cuba`, `djibouti`, `dominica`, `dominican_republic`, `equatorial_guinea`, `eritrea`, `gabon`, `gambia`, `germany`, `greece`, `guinea`, `iceland`, `lesotho`, `liechtenstein`, `luxembourg`, `mali`, `malta`, `mauritania`, `mauritius`, `mongolia`, `mozambique`, `nepal`, `palestine`, `republic_of_ireland`, `republic_of_the_congo`, `saint_vincent_and_the_grenadines`, `senegal`, `seychelles`, `somalia`, `sri_lanka`, `sudan`, `suriname`, `syria`, `timor_leste`, `tunisia`, `vatican_city`, `venezuela`, `zambia`, `zimbabwe`

## Caveats
- Section 4 and 7 depend on the article text; an article with no code table can hide a real Israel code.
- Section 1 values come from the code; I did not re-check each against its article.
- Only India's package was changed.

## Italy diplomatic note
Implemented: `ItalyPlates.diplomatic` (CD), `consular` (CC), `unitedNations` (UN), `unitedNationsSpecialists` (UNP), `unitedNationsTransit` (UNT); `ItalyMissions.restriction` refuses `HL` on the `code` group; `ItalyDiplomaticValidator`; tests in `italy_plate/test/diplomatic_test.dart`; goldens `it_diplomatic`, `it_consular`, `it_unp`. Not done: the country-code table as data, the Republic emblem.

Current format (since 1985): `CD 0213 XG` (corps diplomatique), `CC 0213 AF` (consular), `UNP 147 AA` / `UN 000 AA` / `UNT 000 AA` (United Nations). Blue prefix, black 4-digit (CD/CC) or 3-digit (UN) number, blue two-letter country code, dots between groups, 34 × 11 cm, Italian emblem top-left and the `I` oval top-right. `Q` and `V` are not used on consular plates. The country-code table is in the article; `HL` = Israel is the value to refuse. Flattened reference photos for `CD 0213 XG` and `UNP 147 AA` already exist in `.plateref/it`.
