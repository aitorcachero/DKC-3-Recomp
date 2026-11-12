cmake_minimum_required(VERSION 3.20)
project(Dkc3SNESRecomp C CXX)

set(CMAKE_C_STANDARD 11)

# Release pin for lobby matching. Release builds stamp the VERSION file so two
# peers can prove they are the same build; everything else stamps "dev".
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION" _GAME_VER_RAW)
string(STRIP "${_GAME_VER_RAW}" GAME_RELEASE_VERSION)
set(SNESRECOMP_BUILD_VERSION "" CACHE STRING
    "Lobby release pin (empty = Release uses VERSION, else dev)")
if(SNESRECOMP_BUILD_VERSION STREQUAL "")
    get_property(_is_multi GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
    if(_is_multi)
        set(SNESRECOMP_BUILD_VERSION "$<IF:$<CONFIG:Release>,${GAME_RELEASE_VERSION},dev>")
    elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
        set(SNESRECOMP_BUILD_VERSION "${GAME_RELEASE_VERSION}")
    else()
        set(SNESRECOMP_BUILD_VERSION "dev")
    endif()
endif()

set(SNESRECOMP_ROOT "${CMAKE_SOURCE_DIR}/snesrecomp" CACHE PATH
    "Path to the snesrecomp checkout used by this game")
if(NOT EXISTS "${SNESRECOMP_ROOT}/runner/runner.cmake")
    message(FATAL_ERROR
        "snesrecomp submodule missing at ${SNESRECOMP_ROOT}.\n"
        "Run: git submodule update --init --recursive")
endif()

set(SNESRECOMP_ENABLE_MODS ON CACHE BOOL
    "Mod package loader + trusted plugins (required for every title)" FORCE)
include(${SNESRECOMP_ROOT}/runner/runner.cmake)

set(DKC3_SOURCES
    ${SNESRECOMP_RUNNER_SOURCES}
    src/main.c
    src/host_contract.c
    src/game_rtl.c
    src/gen_stubs.c
)

if(ANDROID)
    add_library(Dkc3SNESRecomp SHARED ${DKC3_SOURCES})
    set_target_properties(Dkc3SNESRecomp PROPERTIES OUTPUT_NAME main)
else()
    add_executable(Dkc3SNESRecomp ${DKC3_SOURCES})
endif()

snesrecomp_rom_identity(Dkc3SNESRecomp ${CMAKE_SOURCE_DIR}/rom_identity.txt)
snesrecomp_target_generated_code(Dkc3SNESRecomp ${CMAKE_SOURCE_DIR}/src/gen)
snesrecomp_target_mod_catalog(Dkc3SNESRecomp ${CMAKE_SOURCE_DIR}/mods/preloaded)

target_include_directories(Dkc3SNESRecomp PRIVATE
    ${SNESRECOMP_RUNNER_INCLUDE_DIRS}
    ${SNESRECOMP_ROOT}/runner/src/desktop
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/recomp
)
target_link_libraries(Dkc3SNESRecomp PRIVATE ${SNESRECOMP_RUNNER_LIBRARIES})
target_compile_definitions(Dkc3SNESRecomp PRIVATE
    SNES_GAME_VERSION="${SNESRECOMP_BUILD_VERSION}"
    SNES_GAME_TITLE="Donkey Kong Country 3"
)
snesrecomp_target_sdl(Dkc3SNESRecomp)
snesrecomp_target_desktop_host(Dkc3SNESRecomp)
snesrecomp_target_rom_cache(Dkc3SNESRecomp)

set(RECOMP_UI_ROOT "${CMAKE_SOURCE_DIR}/recomp-ui" CACHE PATH
    "Root directory of the recomp-ui launcher repo" FORCE)
if(NOT EXISTS "${RECOMP_UI_ROOT}/recomp_ui.cmake")
    message(FATAL_ERROR
        "recomp-ui missing at ${RECOMP_UI_ROOT}.\n"
        "Run: git submodule update --init --recursive recomp-ui")
endif()
include(${RECOMP_UI_ROOT}/recomp_ui.cmake)
recomp_target_launcher_ui(Dkc3SNESRecomp CONSOLE snes
    BOXART "${CMAKE_SOURCE_DIR}/launcher_assets/img/boxart.tga")

if(NOT ANDROID)
    target_sources(Dkc3SNESRecomp PRIVATE
        ${SNESRECOMP_ROOT}/host/snesrecomp_codegen_host.c)
    target_include_directories(Dkc3SNESRecomp PRIVATE
        ${SNESRECOMP_ROOT}/host
        ${RECOMP_UI_ROOT}/src)
endif()

# Auto-stage launcher deluxe poster into target directory
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${PROJECT_NAME}>/assets/img
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_SOURCE_DIR}/assets/img/poster.bmp" $<TARGET_FILE_DIR:${PROJECT_NAME}>/assets/img/poster.bmp
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_SOURCE_DIR}/assets/img/poster.png" $<TARGET_FILE_DIR:${PROJECT_NAME}>/assets/img/poster.png
    VERBATIM)
