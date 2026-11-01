package plates.ui

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import plates.core.input.PlateController

/** [D1] Emits [selector]'s result each time it changes, starting with the current one. */
fun <T> PlateController.select(selector: (PlateController) -> T): Flow<T> =
    changes.map { selector(this) }.distinctUntilChanged()
