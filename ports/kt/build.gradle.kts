import org.jetbrains.kotlin.gradle.ExperimentalWasmDsl

plugins {
    kotlin("multiplatform") version "2.2.20"
    kotlin("plugin.serialization") version "2.2.20"
}

kotlin {
    jvmToolchain(21)
    jvm()
    js(IR) {
        browser()
        binaries.executable()
    }
    @OptIn(ExperimentalWasmDsl::class)
    wasmJs {
        browser()
        binaries.executable()
    }

    sourceSets {
        commonMain.dependencies {
            implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.9.0")
            implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.10.2")
        }
        webMain.dependencies {
            implementation("org.jetbrains.kotlinx:kotlinx-browser:0.5.0")
        }
        jvmTest.dependencies {
            implementation(kotlin("test"))
        }
    }
}

// Vectors live outside the project; tests read them from here.
tasks.withType<Test>().configureEach {
    systemProperty("plates.vectors", rootDir.resolve("../vectors").canonicalPath)
    // `-Pstubs=skip` skips the vector tests of [D4-code] units that are still stubs (oracle_all).
    systemProperty("plates.stubs", providers.gradleProperty("stubs").getOrElse("fail"))
}
