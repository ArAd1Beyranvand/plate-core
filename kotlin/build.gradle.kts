import java.security.MessageDigest
import org.jetbrains.kotlin.gradle.ExperimentalWasmDsl

plugins {
    kotlin("multiplatform") version "2.2.20"
    kotlin("plugin.serialization") version "2.2.20"
}

// The country is picked at build time (W7): `-Pcountry=germany` generates the one entry point that links it.
val country = providers.gradleProperty("country").getOrElse("germany")
val galleryOrigin = providers.gradleProperty("galleryOrigin").getOrElse("")
val entryDir = layout.buildDirectory.dir("generated/entry")
val genEntry = tasks.register("genEntry") {
    inputs.property("country", country)
    inputs.property("origin", galleryOrigin)
    outputs.dir(entryDir)
    doLast {
        val f = entryDir.get().file("Entry.kt").asFile
        f.parentFile.mkdirs()
        f.writeText(
            "package plates.embed\n\nfun main() = startShell(\"$country\", ${if (galleryOrigin.isEmpty()) "null" else "\"$galleryOrigin\""}) { plates.countries.$country.country }\n",
        )
    }
}
tasks.matching { it.name.startsWith("compileKotlin") || it.name.endsWith("SourcesJar") }.configureEach { dependsOn(genEntry) }

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
        webMain { kotlin.srcDir(entryDir) }
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

// `./gradlew webBuild -Pcountry=germany` → deploy/components/<slug>/kotlin/: index.html plus the JS and Wasm builds, each in a
// content-hashed folder (immutable); index.html loads exactly one of them.
tasks.register("webBuild") {
    val dists = listOf("jsBrowserDistribution" to "js", "wasmJsBrowserDistribution" to "wasm")
    dists.forEach { dependsOn(it.first) }
    val out = rootDir.resolve("../../deploy/components/${country.replace('_', '-')}/kotlin")
    val template = layout.projectDirectory.file("web/index.html")
    doLast {
        val target = out.also { it.deleteRecursively(); it.mkdirs() }
        val hashed = dists.associate { (task, kind) ->
            val dir = tasks.getByName(task).outputs.files.first { it.isDirectory }
            val md5 = MessageDigest.getInstance("MD5")
            dir.walkTopDown().filter { it.isFile }.sortedBy { it.name }.forEach { md5.update(it.readBytes()) }
            val name = "$kind-" + md5.digest().joinToString("") { "%02x".format(it) }.take(10)
            dir.copyRecursively(File(target, name))
            kind to name
        }
        // Package assets (flags, decals) are served from packages/<pkg>/<path> next to index.html, as opsToSvg resolves them.
        rootDir.resolve("../data/countries/${country}_plate.json").takeIf { it.isFile }?.let { data ->
            Regex("\"package\"\\s*:\\s*\"([^\"]+)\"\\s*,\\s*\"path\"\\s*:\\s*\"([^\"]+)\"").findAll(data.readText()).forEach { m ->
                val (pkg, path) = m.destructured
                rootDir.resolve("../../$pkg/flutter/$path").takeIf { it.isFile }?.copyTo(File(target, "packages/$pkg/$path"), overwrite = true)
            }
        }
        fun seo(key: String) = ProcessBuilder("python3", rootDir.resolve("../web/seo.py").path, country, "kotlin", "--key", key)
            .redirectErrorStream(true).start().let { p -> p.inputStream.bufferedReader().readText().trim().also { check(p.waitFor() == 0) { it } } }
        val slots = mapOf(
            "title" to seo("title"), "description" to seo("description"), "canonical" to seo("canonical"),
            "h1" to seo("h1"), "text" to seo("text"), "origin" to galleryOrigin, "js" to hashed.getValue("js"), "wasm" to hashed.getValue("wasm"),
        )
        File(target, "index.html").writeText(template.asFile.readText().replace(Regex("\\{\\{(\\w+)\\}\\}")) { slots.getValue(it.groupValues[1]) })
    }
}
