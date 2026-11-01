package plates.countries.russia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.alphabet.AlphabetInput

// Keys of RussiaMissions's register.
private val russiaMissions = setOf(
    "001", "002", "003", "004", "005", "006", "007", "008", "009", "010", "011", "012",
    "013", "014", "015", "016", "017", "018", "019", "020", "021", "022", "023", "024",
    "025", "026", "027", "028", "029", "030", "031", "032", "033", "034", "035", "036",
    "037", "038", "039", "040", "041", "042", "043", "044", "045", "047", "048", "049",
    "050", "051", "052", "053", "054", "055", "056", "057", "058", "059", "060", "061",
    "062", "063", "064", "065", "066", "067", "068", "069", "070", "071", "072", "073",
    "074", "075", "076", "077", "078", "079", "080", "081", "082", "083", "084", "085",
    "086", "087", "088", "089", "090", "091", "092", "093", "094", "095", "096", "097",
    "098", "099", "100", "101", "102", "103", "104", "105", "106", "107", "108", "109",
    "110", "111", "112", "113", "114", "115", "116", "117", "118", "119", "120", "121",
    "122", "123", "124", "125", "126", "128", "129", "130", "131", "132", "133", "134",
    "135", "136", "137", "138", "139", "140", "141", "142", "143", "144", "145", "146",
    "147", "148", "149", "150", "151", "152", "153", "154", "155", "156", "157", "158",
    "159", "160", "161", "162", "163", "164", "165", "166", "167", "168", "169", "499",
    "500", "501", "502", "503", "504", "505", "506", "507", "508", "509", "510", "511",
    "512", "514", "515", "516", "517", "518", "520", "521", "522", "523", "524", "525",
    "526", "527", "528", "529", "530", "531", "532", "533", "534", "535", "555", "556",
    "557", "559", "900",
)

// Keys of RussiaRegions's registers.
private val regionCodes = setOf(
    "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "102", "105",
    "11", "113", "116", "12", "121", "122", "123", "124", "125", "126", "13", "131",
    "133", "134", "136", "138", "14", "142", "147", "15", "150", "152", "154", "155",
    "156", "159", "16", "161", "163", "164", "166", "17", "172", "173", "174", "177",
    "178", "18", "186", "19", "190", "193", "196", "197", "198", "199", "20", "21",
    "22", "224", "23", "24", "25", "250", "252", "26", "27", "28", "29", "30",
    "31", "32", "323", "33", "34", "35", "36", "37", "38", "39", "40", "41",
    "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53",
    "54", "55", "550", "56", "57", "58", "59", "60", "61", "62", "63", "64",
    "65", "66", "67", "68", "69", "70", "702", "71", "716", "72", "73", "74",
    "75", "750", "76", "761", "763", "77", "774", "777", "778", "78", "79", "790",
    "797", "799", "83", "86", "87", "88", "89", "90", "91", "93", "94", "95",
    "96", "97", "977", "98", "99", "997",
)

private val militaryCodes = setOf(
    "09", "10", "12", "14", "15", "16", "17", "18", "20", "21", "23", "25",
    "26", "27", "29", "32", "34", "35", "39", "43", "45", "50", "56", "65",
    "67",
)

/** Judges a registration on any RussiaPlates spec. Reports, never bars a keystroke. The region is a formation code on the military plate. */
class RussiaValidator : GatedPlateValidator() {
    override val gateGroup = "region"

    override fun judge(entry: PlateEntry): PlateValidation {
        val spec = entry.spec
        for (i in spec.slots.indices) {
            val slot = spec.slots[i]
            val value = entry.group(spec.textGroups[i].key!!)
            val whole = slot.alphabet.input == AlphabetInput.chosen
            if (!slot.accepts(value) || (!whole && (value.length < slot.minLength || value.length > slot.length))) {
                return PlateValidation.invalid(REASON_FIELD)
            }
        }
        val region = entry.group("region")
        if (spec.id == "ru.diplomatic") {
            if (entry.group("code") !in russiaMissions) return PlateValidation.invalid(REASON_MISSION)
            val want = if (entry.group("status") == "CD") 1 else 3
            if (entry.group("number").length != want) return PlateValidation.invalid(REASON_NUMBER)
        }
        val known = if (spec.id == "ru.military") region in militaryCodes else region in regionCodes
        if (!known) return PlateValidation.invalid(REASON_REGION)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_FIELD = "A field has the wrong length or letters."
        const val REASON_REGION = "The region code is not in use."
        const val REASON_MISSION = "The mission code is not in use."
        const val REASON_NUMBER = "The diplomatic number is one digit after CD, three after D or T."
    }
}
