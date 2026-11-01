package plates.core.values

/** The EU's twelve gold stars, drawn rather than shipped, for every EU country package to share. */
object EuropeanStars {
    private val gold = Color(0xFFFFCC00)

    /** Just the ring, on no field, for a panel that is already blue (46 x 70.4). */
    val band = PlateDrawing(46.0, 70.4, listOf(PlateStarRingShape(23.0, 35.2, 14.36, 2.9, 12, gold)))

    /** The EU flag: 3:2, blue, ring of twelve stars at its centre. */
    val flag = PlateDrawing(
        900.0, 600.0,
        listOf(
            PlateRectShape(0.0, 0.0, 900.0, 600.0, Color(0xFF003399)),
            PlateStarRingShape(450.0, 300.0, 200.0, 37.5, 12, gold),
        ),
    )
}
