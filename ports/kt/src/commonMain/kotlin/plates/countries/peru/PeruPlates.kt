package plates.countries.peru

object PeruPlates {
    fun _stickerText(group: (String) -> String): String? {
        val register = group("register")
        val serial = group("serial")
        if (register.isEmpty() && serial.isEmpty()) return null
        return "$register-$serial"
    }
}
