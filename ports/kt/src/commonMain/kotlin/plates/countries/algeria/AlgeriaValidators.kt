package plates.countries.algeria

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

/** The vehicle classes the first digit of the `type` group names, by digit. */
object AlgeriaVehicleClasses {
    val names: Map<String, String> = mapOf(
        "1" to "Private vehicle",
        "2" to "Truck",
        "3" to "Commercial vehicle",
        "4" to "Bus",
        "5" to "Tractor unit",
        "6" to "Other tractor",
        "7" to "Special vehicle",
        "8" to "Trailer",
        "9" to "Motorcycle",
    )
}

/**
 * The wilaya codes ending a civil plate. 01–48 are the original wilayas,
 * 49–58 issued since January 2022; 59–69 are issued from January 2027 and are accepted here.
 */
object AlgeriaWilayas {
    val names: Map<String, String> = mapOf(
        "01" to "Adrar", "02" to "Chlef", "03" to "Laghouat", "04" to "Oum El Bouaghi",
        "05" to "Batna", "06" to "Béjaïa", "07" to "Biskra", "08" to "Béchar",
        "09" to "Blida", "10" to "Bouïra", "11" to "Tamanrasset", "12" to "Tébessa",
        "13" to "Tlemcen", "14" to "Tiaret", "15" to "Tizi Ouzou", "16" to "Algiers",
        "17" to "Djelfa", "18" to "Jijel", "19" to "Sétif", "20" to "Saïda",
        "21" to "Skikda", "22" to "Sidi Bel Abbès", "23" to "Annaba", "24" to "Guelma",
        "25" to "Constantine", "26" to "Médéa", "27" to "Mostaganem", "28" to "M'Sila",
        "29" to "Mascara", "30" to "Ouargla", "31" to "Oran", "32" to "El Bayadh",
        "33" to "Illizi", "34" to "Bordj Bou Arréridj", "35" to "Boumerdès",
        "36" to "El Tarf", "37" to "Tindouf", "38" to "Tissemsilt", "39" to "El Oued",
        "40" to "Khenchela", "41" to "Souk Ahras", "42" to "Tipaza", "43" to "Mila",
        "44" to "Aïn Defla", "45" to "Naâma", "46" to "Aïn Témouchent",
        "47" to "Ghardaïa", "48" to "Relizane", "49" to "Timimoun",
        "50" to "Bordj Badji Mokhtar", "51" to "Ouled Djellal", "52" to "Béni Abbès",
        "53" to "In Salah", "54" to "In Guezzam", "55" to "Touggourt", "56" to "Djanet",
        "57" to "El M'Ghair", "58" to "El Menia", "59" to "Aflou", "60" to "Barika",
        "61" to "El Kantara", "62" to "Bir El Ater", "63" to "El Aricha",
        "64" to "Ksar Chellala", "65" to "Aïn Oussera", "66" to "Messaad",
        "67" to "Ksar El Boukhari", "68" to "Bousaâda",
        "69" to "El Abiodh Sidi Cheikh",
    )
}

/**
 * Judges a civil Algerian registration on `AlgeriaPlates.singleLine` or
 * `twoLine`. Reports, never bars a keystroke.
 */
class AlgeriaValidator : GatedPlateValidator() {
    override val gateGroup = "wilaya"

    override fun judge(entry: PlateEntry): PlateValidation =
        validateFields(entry.group("serial"), entry.group("type"), entry.group("wilaya"))

    companion object {
        const val REASON_SERIAL = "The serial is five digits."
        const val REASON_CLASS = "The vehicle class is 1 to 9."
        const val REASON_TYPE = "The middle group is a class digit and two year digits."
        const val REASON_WILAYA = "The wilaya code is 01 to 69."

        fun validateFields(serial: String, type: String, wilaya: String): PlateValidation {
            if (!isDigitsOfLength(serial, 5)) return PlateValidation.invalid(REASON_SERIAL)
            if (!isDigitsOfLength(type, 3)) return PlateValidation.invalid(REASON_TYPE)
            if (!AlgeriaVehicleClasses.names.containsKey(type.substring(0, 1))) {
                return PlateValidation.invalid(REASON_CLASS)
            }
            if (!AlgeriaWilayas.names.containsKey(wilaya)) return PlateValidation.invalid(REASON_WILAYA)
            return PlateValidation.valid
        }
    }
}

/** Judges an `AlgeriaPlates.diplomatic` value: a serial, then two two-digit codes. */
class AlgeriaDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "mission"

    override fun judge(entry: PlateEntry): PlateValidation {
        val serial = entry.group("serial")
        if (serial.isEmpty() || !isDigits(serial) ||
            !isDigitsOfLength(entry.group("status"), 2) ||
            !isDigitsOfLength(entry.group("mission"), 2)
        ) {
            return PlateValidation.invalid(REASON_DIGITS)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_DIGITS = "A diplomatic plate is a serial and two two-digit codes."
    }
}
