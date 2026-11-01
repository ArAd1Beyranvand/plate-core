package plates.core.values

/** Anything a flag slot can show: a file a package ships, or a [PlateDrawing]. JSON kinds: "drawing" | "svg" | "raster". */
sealed interface PlateGraphic

/** A picture built from filled [shapes] in a [width] x [height] space; later shapes cover earlier ones. */
data class PlateDrawing(val width: Double, val height: Double, val shapes: List<PlateShape>) : PlateGraphic

/** An image a country package ships, addressed by the package that owns it. */
sealed interface PlateAsset : PlateGraphic {
    val path: String
    val `package`: String
}

/** Rasterised at device-pixel size, so a detailed emblem stays crisp at plate scale. */
data class SvgPlateAsset(override val path: String, override val `package`: String) : PlateAsset

data class RasterPlateAsset(override val path: String, override val `package`: String) : PlateAsset
