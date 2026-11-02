package plates.core.values

import plates.loadVectors
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class ValuesTest {
    @Test
    fun boxRect() {
        val b = PlateBox(1.0, 2.0, 3.0, 4.0)
        assertEquals(Rect(1.0, 2.0, 4.0, 6.0), b.rect)
        assertEquals(4.0, b.right)
        assertEquals(6.0, b.bottom)
    }

    @Test
    fun europeanStars() {
        assertEquals(0xFF003399.toInt(), (EuropeanStars.flag.shapes[0] as PlateRectShape).color)
        assertEquals(12, (EuropeanStars.band.shapes[0] as PlateStarRingShape).count)
    }

    @Test
    fun valueVectorsLoad() {
        assertTrue(loadVectors("core/values.json").isNotEmpty())
    }
}
