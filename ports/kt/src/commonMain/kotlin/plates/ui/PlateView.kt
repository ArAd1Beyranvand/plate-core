package plates.ui

import plates.core.input.PlateController
import plates.core.theme.PlateTheme
import plates.core.values.PlateCountry
import plates.core.values.PlateSpec

/** [D1] PlateTextView as a formatter: the slot values in order, empty slots skipped. */
fun plateText(values: List<String?>) = values.filterNot { it.isNullOrEmpty() }.joinToString("")

/** [D1] Read-only plate: spec + values in, SVG out; [emptySvg] while every slot is empty, if set. */
fun plateViewSvg(
    spec: PlateSpec<*>,
    values: List<String?>,
    theme: PlateTheme? = null,
    country: PlateCountry? = null,
    emptySvg: String? = null,
): String {
    if (emptySvg != null && values.all { it.isNullOrEmpty() }) return emptySvg
    return PlateCanvas(spec, PlateController(spec, values), theme = theme, country = country).svg()
}
