package plates

import kotlin.test.Test
import kotlin.test.assertTrue

class SmokeTest {
    @Test
    fun alphabetVectorsLoad() {
        assertTrue(loadVectors("core/alphabet.json").isNotEmpty())
    }
}
