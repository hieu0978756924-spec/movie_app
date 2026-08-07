allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    val patchInAppWebView = Runnable {
        if (name == "flutter_inappwebview_android") {
            val android = extensions.findByName("android")
            if (android != null) {
                try {
                    val buildTypes = android.javaClass.getMethod("getBuildTypes").invoke(android) as org.gradle.api.NamedDomainObjectContainer<*>
                    buildTypes.all {
                        val getProguardFiles = this.javaClass.getMethod("getProguardFiles")
                        val files = getProguardFiles.invoke(this) as MutableCollection<*>
                        files.removeIf { file -> file.toString().contains("proguard-android.txt") }
                    }
                } catch (e: Exception) {
                    println("Failed to patch flutter_inappwebview_android proguard: $e")
                }
            }
        }
    }

    if (state.executed) {
        patchInAppWebView.run()
    } else {
        afterEvaluate {
            patchInAppWebView.run()
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
