package plates.render

import plates.core.values.Color
import plates.core.values.PlateDrawing
import plates.core.values.PlateGraphic
import plates.core.values.RasterPlateAsset
import plates.core.values.Rect
import plates.core.values.SvgPlateAsset

/** [D6] PlateFlag: a drawing stretched to [r], or an asset the host resolves; an optional hairline frame. */
fun paintFlag(c: DisplayList, flag: PlateGraphic?, r: Rect, borderColor: Color? = null) {
    when (flag) {
        is PlateDrawing -> {
            c.save()
            c.translate(r.left, r.top)
            paintDrawing(c, flag, r.width, r.height, DrawingFit.fill)
            c.restore()
        }
        is SvgPlateAsset -> c.asset("svg", flag.`package`, flag.path, r)
        is RasterPlateAsset -> c.asset("raster", flag.`package`, flag.path, r)
        null -> {}
    }
    if (borderColor != null) c.rect(deflate(r, 0.5), Paint(borderColor, 1.0, StrokeCap.butt, StrokeJoin.miter))
}
