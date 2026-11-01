package plates.countries.madagascar

object MadagascarRegions {
    private val provinces: Map<String, String> = mapOf(
        "A" to "Toamasina",
        "D" to "Antsiranana",
        "F" to "Fianarantsoa",
        "M" to "Mahajanga",
        "T" to "Antananarivo",
        "U" to "Toliara",
    )

    fun lookup(letter: String): String? = provinces[letter]

    fun captionOf(group: (String) -> String): String? {
        val series = group("series")
        return if (series.isEmpty()) null else lookup(series.substring(0, 1))
    }

    fun temporaryCaptionOf(group: (String) -> String): String? {
        val series = group("series")
        return if (series.length == 3 && series.startsWith("WW")) lookup(series.substring(2, 3)) else null
    }

    fun dealerCaptionOf(group: (String) -> String): String? = lookup(group("series"))
}
