# Copyright 2016, alex at staticlibs.net
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cmake_minimum_required ( VERSION 2.8.12 )

# asm compilation
macro ( openssl_asm_compile _path )
    string ( REGEX REPLACE "/[^/]*$" "/" _dir ${_path} )
    string ( REGEX REPLACE "^.*/" "" _name ${_path} )
    string ( REGEX REPLACE "\\..*$" "" _name ${_name} )
    if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_msvc" )
        add_custom_command ( OUTPUT ${_name}.obj
                COMMAND perl ${_dir}/${_name}.pl ${${PROJECT_NAME}_ASM_PERL_OPTIONS} > ${_name}.asm
                COMMAND nasm ${${PROJECT_NAME}_ASM_NASM_OPTIONS} -o ${_name}.obj ${_name}.asm
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR} )
        set_source_files_properties ( ${PROJECT_BINARY_DIR}/${_name}.asm PROPERTIES GENERATED 1 )
        set ( ${PROJECT_NAME}_ASMOBJ ${${PROJECT_NAME}_ASMOBJ} ${PROJECT_BINARY_DIR}/${_name}.obj )
    elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_amd64_msvc" )
        add_custom_command ( OUTPUT ${_name}.obj
                COMMAND set ASM=nasm -f win64 -DNEAR -Ox -g
                COMMAND perl ${_dir}/${_name}.pl ${_name}.asm
                COMMAND nasm ${${PROJECT_NAME}_ASM_NASM_OPTIONS} -o ${_name}.obj ${_name}.asm
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR} )
        set_source_files_properties ( ${PROJECT_BINARY_DIR}/${_name}.asm PROPERTIES GENERATED 1 )
        set ( ${PROJECT_NAME}_ASMOBJ ${${PROJECT_NAME}_ASMOBJ} ${PROJECT_BINARY_DIR}/${_name}.obj )
    elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "linux_amd64_gcc" )
        add_custom_command ( OUTPUT ${_name}.s
                COMMAND perl ${_dir}/${_name}.pl elf > ${_name}.s
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR} )
        set_source_files_properties ( ${PROJECT_BINARY_DIR}/${_name}.s PROPERTIES GENERATED 1 )
        set_source_files_properties ( ${PROJECT_BINARY_DIR}/${_name}.s PROPERTIES LANGUAGE C )
        set ( ${PROJECT_NAME}_ASMOBJ ${${PROJECT_NAME}_ASMOBJ} ${PROJECT_BINARY_DIR}/${_name}.s )
    else ( )
        message ( FATAL_ERROR "Unsupported toolchain for NASM: [${${PROJECT_NAME}_TOOLCHAIN}]" )
    endif ( )

endmacro ( )

