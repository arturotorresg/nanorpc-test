from conans import ConanFile, tools, CMake

class ComputerVisionConan(ConanFile):
    name = "SCV"
    version = "0.0.1"
    user = "CV"
    channel = "SDK"
    settings = "os", "compiler", "build_type", "arch"
    description = "Computer Vision library to use cameras and its information"
    generators = "cmake", "virtualrunenv"

    def requirements(self):
        self.requires("Boost/1.75.0@CV/lib")
        self.requires("Nanorpc/1.1.1@CV/lib")

    def package(self):
        self.copy("*.h", dst="include", src="lib")
        self.copy("*.so", dst="lib", keep_path=False)

    # def package_info(self):
        # self.cpp_info.libs = tools.collect_libs(self)
