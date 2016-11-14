# Copyright 2016, akashche at redhat.com
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
project ( lookaside_openssl C )
include ( ${CMAKE_CURRENT_LIST_DIR}/../macros.cmake )

set ( ${PROJECT_NAME}_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/../../../../lookaside/openssl )

# standalone build
if ( NOT DEFINED STATICLIB_TOOLCHAIN )
    if ( NOT DEFINED ${PROJECT_NAME}_TOOLCHAIN )
        if ( WIN32 )
            if ( CMAKE_SIZEOF_VOID_P EQUAL 8 )
                set ( ${PROJECT_NAME}_TOOLCHAIN "windows_amd64_msvc" )
            else ( )
                set ( ${PROJECT_NAME}_TOOLCHAIN "windows_i386_msvc" )
            endif ( )
        elseif ( APPLE )
            set ( ${PROJECT_NAME}_TOOLCHAIN "macosx_amd64_clang" )
        elseif ( UNIX )
            set ( ${PROJECT_NAME}_TOOLCHAIN "linux_amd64_gcc" )
        else ( )
            message ( FATAL_ERROR "Cannot determine toolchain to use, please specify [${PROJECT_NAME}_TOOLCHAIN]" )
        endif ( )
    endif ( )
else ( )
    set ( ${PROJECT_NAME}_TOOLCHAIN ${STATICLIB_TOOLCHAIN} )
endif ( )

# options
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_msvc" )
    set ( ${PROJECT_NAME}_DEFINITIONS
            -DOPENSSL_THREADS
            -DDSO_WIN32
            -DOPENSSL_SYSNAME_WIN32
            -DWIN32_LEAN_AND_MEAN
            -DL_ENDIAN
            -D_CRT_SECURE_NO_DEPRECATE
            -Dinline=__inline
            -Dsecure_getenv=getenv
            -DEAI_SYSTEM=EAI_FAIL
            -D_WIN32_WINNT=0x0501
            -Dstrcasestr=strstr
            -DOPENSSL_BN_ASM_PART_WORDS
            -DOPENSSL_IA32_SSE2
            -DOPENSSL_BN_ASM_MONT
            -DOPENSSL_BN_ASM_GF2m
            -DSHA1_ASM
            -DSHA256_ASM
            -DSHA512_ASM
            -DMD5_ASM
            -DRMD160_ASM
            -DAES_ASM
            -DVPAES_ASM
            -DWHIRLPOOL_ASM
            -DGHASH_ASM
            -DOPENSSL_NO_RC5
            -DOPENSSL_NO_MD2
            -DOPENSSL_NO_MDC2
            -DOPENSSL_NO_SRP
            -DOPENSSL_NO_KRB5
            -DOPENSSL_NO_GOST
            -DOPENSSL_NO_JPAKE
            -DOPENSSL_NO_EC2M
            -DOPENSSL_NO_DYNAMIC_ENGINE
            -DMK1MF_BUILD
            -DMK1MF_PLATFORM_VC_WIN32 )
        set ( ${PROJECT_NAME}_ASM_PERL_OPTIONS 
            win32n
            ${${PROJECT_NAME}_DEFINITIONS} )
    set ( ${PROJECT_NAME}_ASM_NASM_OPTIONS
            -f win32 )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_amd64_msvc" )
    set ( ${PROJECT_NAME}_DEFINITIONS
            -DOPENSSL_THREADS
            -DDSO_WIN32
            -DOPENSSL_SYSNAME_WIN32
            -DWIN32_LEAN_AND_MEAN
            -DL_ENDIAN
            -DUNICODE
            -D_UNICODE
            -D_CRT_SECURE_NO_DEPRECATE
            -Dinline=__inline
            -Dsecure_getenv=getenv
            -DEAI_SYSTEM=EAI_FAIL
            -D_WIN32_WINNT=0x0601
            -Dstrcasestr=strstr
            -DOPENSSL_IA32_SSE2
            -DOPENSSL_BN_ASM_MONT
            -DOPENSSL_BN_ASM_MONT5
            -DOPENSSL_BN_ASM_GF2m
            -DSHA1_ASM
            -DSHA256_ASM
            -DSHA512_ASM
            -DMD5_ASM
            -DAES_ASM
            -DVPAES_ASM
            -DBSAES_ASM
            -DWHIRLPOOL_ASM
            -DGHASH_ASM
            -DOPENSSL_NO_RC5
            -DOPENSSL_NO_MD2
            -DOPENSSL_NO_MDC2
            -DOPENSSL_NO_SRP
            -DOPENSSL_NO_KRB5
            -DOPENSSL_NO_GOST
            -DOPENSSL_NO_JPAKE
            -DOPENSSL_NO_EC2M
            -DOPENSSL_NO_DYNAMIC_ENGINE
            -DMK1MF_BUILD
            -DMK1MF_PLATFORM_VC_WIN64A )
    set ( ${PROJECT_NAME}_ASM_NASM_OPTIONS
            -f
            win64
            -DNEAR
            -Ox
            -g )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "linux_amd64_gcc" )
    set ( ${PROJECT_NAME}_DEFINITIONS
            -DOPENSSL_THREADS
            -D_REENTRANT
            -DL_ENDIAN
            -DTERMIO
            -DOPENSSL_IA32_SSE2
            -DOPENSSL_BN_ASM_MONT
            -DOPENSSL_BN_ASM_MONT5
            -DOPENSSL_BN_ASM_GF2m
            -DSHA1_ASM
            -DSHA256_ASM
            -DSHA512_ASM
            -DMD5_ASM
            -DAES_ASM
            -DVPAES_ASM
            -DBSAES_ASM
            -DWHIRLPOOL_ASM
            -DGHASH_ASM
            -Dsecure_getenv=getenv )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "android_[^_]+_gcc" )
    set ( ${PROJECT_NAME}_DEFINITIONS
            -DOPENSSL_THREADS
            -D_REENTRANT
            -DL_ENDIAN
            -Dsecure_getenv=getenv )
else ( )
    message ( FATAL_ERROR "Unsupported toolchain: [${PROJECT_NAME}_TOOLCHAIN]" )
endif ( )

# headers
message ( STATUS "Copying headers ..." )

# private
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/e_os.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_os.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/cryptlib.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/cryptlib.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/md32_common.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/md32_common.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/o_time.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/o_time.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/o_str.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/o_str.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/o_dir.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/o_dir.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/constant_time_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/constant_time_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/md4/md4_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/md4_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/md5/md5_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/md5_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/sha/sha_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/sha_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ripemd/rmd_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/rmd_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ripemd/rmdconst.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/rmdconst.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/des_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/des_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/rpc_des.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/rpc_des.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/spr.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/spr.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/des_ver.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/des_ver.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/rc2/rc2_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/rc2_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/rc4/rc4_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/rc4_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/idea/idea_lcl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/idea_lcl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/bf/bf_pi.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/bf_pi.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/bf/bf_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/bf_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/cast/cast_s.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/cast_s.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/cast/cast_lcl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/cast_lcl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/aes_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/aes_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/camellia/cmll_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/cmll_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/seed/seed_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/seed_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/modes/modes_lcl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/modes_lcl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_lcl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/bn_lcl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_prime.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/bn_prime.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/dsa/dsa_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/dsa_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec_lcl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/ec_lcl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ecdh/ech_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/ech_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ecdsa/ecs_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/ecs_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bio_lcl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/bio_lcl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/objects/obj_dat.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/obj_dat.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/objects/obj_xref.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/obj_xref.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/evp_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/evp_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/asn1_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/asn1_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/pcy_int.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/pcy_int.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/cms/cms_lcl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/cms_lcl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/conf/conf_def.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/conf_def.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ui/ui_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/ui_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/whrlpool/wp_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/wp_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl_locl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/ssl_locl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/ssl/kssl_lcl.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/kssl_lcl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/apps/apps.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/apps.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/apps/progs.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/progs.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/apps/s_apps.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/s_apps.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/apps/testdsa.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/testdsa.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/apps/testrsa.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/testrsa.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_4758cca_err.c" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_4758cca_err.c" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_4758cca_err.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_4758cca_err.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_aep_err.c" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_aep_err.c" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_aep_err.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_aep_err.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_atalla_err.c" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_atalla_err.c" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_atalla_err.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_atalla_err.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_cswift_err.c" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_cswift_err.c" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_cswift_err.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_cswift_err.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_gmp_err.c" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_gmp_err.c" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_gmp_err.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_gmp_err.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_chil_err.c" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_chil_err.c" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_chil_err.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_chil_err.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_nuron_err.c" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_nuron_err.c" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_nuron_err.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_nuron_err.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_sureware_err.c" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_sureware_err.c" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_sureware_err.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_sureware_err.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_ubsec_err.c" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_ubsec_err.c" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_ubsec_err.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_ubsec_err.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_capi_err.c" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_capi_err.c" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/engines/e_capi_err.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/e_capi_err.h" COPYONLY )
configure_file( "${CMAKE_CURRENT_LIST_DIR}/include_${${PROJECT_NAME}_TOOLCHAIN}/buildinf.h" "${CMAKE_CURRENT_BINARY_DIR}/include_private/buildinf.h" COPYONLY )

# public
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/e_os2.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/e_os2.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/crypto.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/crypto.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/opensslv.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/opensslv.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/opensslconf.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/opensslconf.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ebcdic.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/ebcdic.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/symhacks.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/symhacks.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ossl_typ.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/ossl_typ.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/md4/md4.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/md4.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/md5/md5.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/md5.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/sha/sha.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/sha.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/hmac/hmac.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/hmac.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/cmac/cmac.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/cmac.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ripemd/ripemd.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/ripemd.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/des.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/des.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/des_old.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/des_old.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/rc2/rc2.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/rc2.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/rc4/rc4.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/rc4.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/idea/idea.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/idea.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/bf/blowfish.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/blowfish.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/cast/cast.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/cast.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/aes.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/aes.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/camellia/camellia.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/camellia.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/seed/seed.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/seed.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/modes/modes.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/modes.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/bn.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/rsa.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/dsa/dsa.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/dsa.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/dso/dso.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/dso.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/dh/dh.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/dh.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/ec.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ecdh/ecdh.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/ecdh.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ecdsa/ecdsa.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/ecdsa.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/buffer/buffer.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/buffer.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bio.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/bio.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/stack/stack.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/stack.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/stack/safestack.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/safestack.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/lhash/lhash.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/lhash.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/rand/rand.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/rand.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/err/err.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/err.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/objects/objects.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/objects.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/objects/obj_mac.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/obj_mac.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/evp.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/evp.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/asn1.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/asn1.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/asn1_mac.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/asn1_mac.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/asn1t.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/asn1t.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/pem/pem.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/pem.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/pem/pem2.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/pem2.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/x509.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_vfy.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/x509_vfy.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/x509v3.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/x509v3.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/cms/cms.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/cms.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/conf/conf.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/conf.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/conf/conf_api.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/conf_api.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/txt_db/txt_db.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/txt_db.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs7/pkcs7.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/pkcs7.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/pkcs12.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/pkcs12.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/comp/comp.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/comp.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/engine.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/engine.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ocsp/ocsp.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/ocsp.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ui/ui.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/ui.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ui/ui_compat.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/ui_compat.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/krb5/krb5_asn.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/krb5_asn.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/pqueue/pqueue.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/pqueue.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/whrlpool/whrlpool.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/whrlpool.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/crypto/ts/ts.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/ts.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/ssl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl2.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/ssl2.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl3.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/ssl3.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl23.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/ssl23.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/ssl/tls1.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/tls1.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/ssl/dtls1.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/dtls1.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/ssl/kssl.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/kssl.h" COPYONLY )
configure_file( "${${PROJECT_NAME}_SOURCE_DIR}/ssl/srtp.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/srtp.h" COPYONLY )
configure_file( "${CMAKE_CURRENT_LIST_DIR}/include_${${PROJECT_NAME}_TOOLCHAIN}/opensslconf.h" "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/opensslconf.h" COPYONLY )

# sources
set ( ${PROJECT_NAME}_SRC )
set ( ${PROJECT_NAME}_ASMOBJ )

# crypto 
set ( ${PROJECT_NAME}_CRYPTO_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cryptlib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/mem.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/mem_dbg.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cversion.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ex_data.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cpt_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ebcdic.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/uid.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/o_time.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/o_str.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/o_dir.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/o_fips.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/o_init.c )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "android_[^_]+_gcc" )
    list ( APPEND ${PROJECT_NAME}_CRYPTO_SRC
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/mem_clr.c )
endif ( ) 
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_SRC} )
source_group ( "crypto" FILES ${${PROJECT_NAME}_CRYPTO_SRC} )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x86cpuid.pl )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_amd64_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x86_64cpuid.pl )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "linux_amd64_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x86_64cpuid.pl )
endif ( )

# crypto/md4 
set ( ${PROJECT_NAME}_CRYPTO_MD4_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/md4/md4_dgst.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/md4/md4_one.c )
    list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_MD4_SRC} )
source_group ( "crypto_md4" FILES ${${PROJECT_NAME}_CRYPTO_MD4_SRC} )

# crypto/md5 
set ( ${PROJECT_NAME}_CRYPTO_MD5_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/md5/md5_dgst.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/md5/md5_one.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_MD5_SRC} )
source_group ( "crypto_md5" FILES ${${PROJECT_NAME}_CRYPTO_MD5_SRC} )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/md5/asm/md5-586.pl )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "[^_]+_amd64_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/md5/asm/md5-x86_64.pl )
endif ( )

# crypto/sha
set ( ${PROJECT_NAME}_CRYPTO_SHA_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/sha/sha_dgst.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/sha/sha1dgst.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/sha/sha_one.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/sha/sha1_one.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/sha/sha256.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/sha/sha512.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_SHA_SRC} )
source_group ( "crypto_sha" FILES ${${PROJECT_NAME}_CRYPTO_SHA_SRC} )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/sha/asm/sha1-586.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/sha/asm/sha256-586.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/sha/asm/sha512-586.pl )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "[^_]+_amd64_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/sha/asm/sha1-x86_64.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/sha/asm/sha512-x86_64.pl )
endif ( )
# special case for sha256
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_amd64_[^_]+" )
    add_custom_command ( OUTPUT sha256-x86_64.obj
            COMMAND set ASM=nasm -f win64 -DNEAR -Ox -g
            COMMAND perl ${${PROJECT_NAME}_SOURCE_DIR}/crypto/sha/asm/sha512-x86_64.pl sha256-x86_64.asm
            COMMAND nasm ${${PROJECT_NAME}_ASM_NASM_OPTIONS} -o sha256-x86_64.obj sha256-x86_64.asm
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} )
    set_source_files_properties ( ${CMAKE_CURRENT_BINARY_DIR}/sha256-x86_64.asm PROPERTIES GENERATED 1 )
list ( APPEND ${PROJECT_NAME}_ASMOBJ ${CMAKE_CURRENT_BINARY_DIR}/sha256-x86_64.obj )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "linux_amd64_[^_]+" )
    # special case for sha256
    add_custom_command ( OUTPUT sha256-x86_64.s
            COMMAND perl ${${PROJECT_NAME}_SOURCE_DIR}/crypto/sha/asm/sha512-x86_64.pl elf > sha256-x86_64.s
            WORKING_DIRECTORY ${PROJECT_BINARY_DIR} )
    set_source_files_properties ( ${PROJECT_BINARY_DIR}/sha256-x86_64.s PROPERTIES GENERATED 1 )
    set_source_files_properties ( ${PROJECT_BINARY_DIR}/sha256-x86_64.s PROPERTIES LANGUAGE C )
    list ( APPEND ${PROJECT_NAME}_ASMOBJ ${PROJECT_BINARY_DIR}/sha256-x86_64.s )
endif ( )

# crypto/hmac
set ( ${PROJECT_NAME}_CRYPTO_HMAC_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/hmac/hmac.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/hmac/hm_ameth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/hmac/hm_pmeth.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_HMAC_SRC} )
source_group ( "crypto_hmac" FILES ${${PROJECT_NAME}_CRYPTO_HMAC_SRC} )

# crypto/cmac
set ( ${PROJECT_NAME}_CRYPTO_CMAC_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cmac/cmac.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cmac/cm_ameth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cmac/cm_pmeth.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_CMAC_SRC} )
source_group ( "crypto_cmac" FILES ${${PROJECT_NAME}_CRYPTO_CMAC_SRC} )

# crypto/ripemd
set ( ${PROJECT_NAME}_CRYPTO_RIPEMD_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ripemd/rmd_dgst.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ripemd/rmd_one.c )
    list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_RIPEMD_SRC} )
source_group ( "crypto_ripemd" FILES ${${PROJECT_NAME}_CRYPTO_RIPEMD_SRC} )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ripemd/asm/rmd-586.pl )
endif ( )

# crypto/des
set ( ${PROJECT_NAME}_CRYPTO_DES_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/set_key.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/ecb_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/cbc_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/ecb3_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/cfb64enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/cfb64ede.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/cfb_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/ofb64ede.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/enc_read.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/enc_writ.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/ofb64enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/ofb_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/str2key.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/pcbc_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/qud_cksm.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/rand_key.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/fcrypt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/xcbc_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/rpc_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/cbc_cksm.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/ede_cbcm_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/des_old.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/des_old2.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/read2pwd.c )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_amd64_[^_]+" )
    list ( APPEND ${PROJECT_NAME}_CRYPTO_DES_SRC
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/des_enc.c
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/fcrypt_b.c )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "android_[^_]+_gcc" )
    list ( APPEND ${PROJECT_NAME}_CRYPTO_DES_SRC
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/des_enc.c
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/fcrypt_b.c )
endif ( ) 
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_DES_SRC} )
source_group ( "crypto_des" FILES ${${PROJECT_NAME}_CRYPTO_DES_SRC} )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/asm/des-586.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/des/asm/crypt586.pl )
endif ( )

# crypto/rc2
set ( ${PROJECT_NAME}_CRYPTO_RC2_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rc2/rc2_ecb.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rc2/rc2_skey.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rc2/rc2_cbc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rc2/rc2cfb64.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rc2/rc2ofb64.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_RC2_SRC} )
source_group ( "crypto_rc2" FILES ${${PROJECT_NAME}_CRYPTO_RC2_SRC} )

# crypto/rc4
set ( ${PROJECT_NAME}_CRYPTO_RC4_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rc4/rc4_utl.c )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "android_[^_]+_gcc" )
    list ( APPEND ${PROJECT_NAME}_CRYPTO_RC4_SRC
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rc4/rc4_enc.c
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rc4/rc4_skey.c )
endif ( )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_RC4_SRC} )
source_group ( "crypto_rc4" FILES ${${PROJECT_NAME}_CRYPTO_RC4_SRC} )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rc4/asm/rc4-586.pl )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "[^_]+_amd64_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rc4/asm/rc4-x86_64.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rc4/asm/rc4-md5-x86_64.pl )
endif ( )

# crypto/idea
set ( ${PROJECT_NAME}_CRYPTO_IDEA_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/idea/i_cbc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/idea/i_cfb64.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/idea/i_ofb64.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/idea/i_ecb.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/idea/i_skey.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_IDEA_SRC} )
source_group ( "crypto_idea" FILES ${${PROJECT_NAME}_CRYPTO_IDEA_SRC} )

# crypto/bf
set ( ${PROJECT_NAME}_CRYPTO_BF_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bf/bf_skey.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bf/bf_ecb.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bf/bf_cfb64.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bf/bf_ofb64.c )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_amd64_[^_]+" )
    list ( APPEND ${PROJECT_NAME}_CRYPTO_BF_SRC
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bf/bf_enc.c )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "android_[^_]+_gcc" )
    list ( APPEND ${PROJECT_NAME}_CRYPTO_BF_SRC
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bf/bf_enc.c )
endif ( ) 
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_BF_SRC} )
source_group ( "crypto_bf" FILES ${${PROJECT_NAME}_CRYPTO_BF_SRC} )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bf/asm/bf-586.pl )
endif ( )

# crypto/cast
set ( ${PROJECT_NAME}_CRYPTO_CAST_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cast/c_skey.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cast/c_ecb.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cast/c_cfb64.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cast/c_ofb64.c )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_amd64_[^_]+" )
    list ( APPEND ${PROJECT_NAME}_CRYPTO_CAST_SRC
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cast/c_enc.c )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "android_[^_]+_gcc" )
    list ( APPEND ${PROJECT_NAME}_CRYPTO_CAST_SRC
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cast/c_enc.c )
endif ( ) 
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_CAST_SRC} )
source_group ( "crypto_cast" FILES ${${PROJECT_NAME}_CRYPTO_CAST_SRC} )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cast/asm/cast-586.pl )
endif ( )

# crypto/aes
set ( ${PROJECT_NAME}_CRYPTO_AES_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/aes_misc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/aes_ecb.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/aes_cfb.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/aes_ofb.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/aes_ctr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/aes_ige.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/aes_wrap.c )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "android_[^_]+_gcc" ) 
    list ( APPEND ${PROJECT_NAME}_CRYPTO_AES_SRC
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/aes_core.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/aes_cbc.c )
endif ( )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_AES_SRC} )
source_group ( "crypto_aes" FILES ${${PROJECT_NAME}_CRYPTO_AES_SRC} )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/asm/aes-586.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/asm/vpaes-x86.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/asm/aesni-x86.pl )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "[^_]+_amd64_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/asm/aes-x86_64.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/asm/vpaes-x86_64.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/asm/bsaes-x86_64.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/asm/aesni-x86_64.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/aes/asm/aesni-sha1-x86_64.pl )
endif ( )

# crypto/camellia
set ( ${PROJECT_NAME}_CRYPTO_CAMELLIA_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/camellia/cmll_ecb.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/camellia/cmll_ofb.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/camellia/cmll_cfb.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/camellia/cmll_ctr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/camellia/cmll_utl.c )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_amd64_[^_]+" )
    list ( APPEND ${PROJECT_NAME}_CRYPTO_CAMELLIA_SRC
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/camellia/cmll_misc.c )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "android_[^_]+_gcc" )
    list ( APPEND ${PROJECT_NAME}_CRYPTO_CAMELLIA_SRC
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/camellia/camellia.c 
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/camellia/cmll_misc.c 
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/camellia/cmll_cbc.c )
endif ( ) 
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_CAMELLIA_SRC} )
source_group ( "crypto_camellia" FILES ${${PROJECT_NAME}_CRYPTO_CAMELLIA_SRC} )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/camellia/asm/cmll-x86.pl )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "[^_]+_amd64_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/camellia/asm/cmll-x86_64.pl )
endif ( )

# crypto/seed
set ( ${PROJECT_NAME}_CRYPTO_SEED_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/seed/seed.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/seed/seed_ecb.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/seed/seed_cbc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/seed/seed_cfb.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/seed/seed_ofb.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_SEED_SRC} )
source_group ( "crypto_seed" FILES ${${PROJECT_NAME}_CRYPTO_SEED_SRC} )

# crypto/modes
set ( ${PROJECT_NAME}_CRYPTO_MODES_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/modes/cbc128.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/modes/ctr128.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/modes/cts128.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/modes/cfb128.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/modes/ofb128.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/modes/gcm128.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/modes/ccm128.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/modes/xts128.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/modes/wrap128.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_MODES_SRC} )
source_group ( "crypto_modes" FILES ${${PROJECT_NAME}_CRYPTO_MODES_SRC} )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/modes/asm/ghash-x86.pl )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "[^_]+_amd64_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/modes/asm/ghash-x86_64.pl )
endif ( )

# crypto/bn
set ( ${PROJECT_NAME}_CRYPTO_BN_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_add.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_div.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_exp.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_ctx.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_mul.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_mod.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_print.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_rand.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_shift.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_word.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_blind.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_kron.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_sqrt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_gcd.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_prime.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_sqr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_recp.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_mont.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_mpi.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_exp2.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_gf2m.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_nist.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_depr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_const.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_x931p.c )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_amd64_[^_]+" )
    list ( APPEND ${PROJECT_NAME}_CRYPTO_BN_SRC
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_asm.c )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "android_[^_]+_gcc" )
    list ( APPEND ${PROJECT_NAME}_CRYPTO_BN_SRC
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/bn_asm.c )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "linux_amd64_gcc+" )
    list ( APPEND ${PROJECT_NAME}_CRYPTO_BN_SRC
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/asm/x86_64-gcc.c )
endif ( ) 
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_BN_SRC} )
source_group ( "crypto_bn" FILES ${${PROJECT_NAME}_CRYPTO_BN_SRC} )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/asm/bn-586.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/asm/co-586.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/asm/x86-mont.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/asm/x86-gf2m.pl )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "[^_]+_amd64_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/asm/x86_64-mont.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/asm/x86_64-mont5.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/asm/x86_64-gf2m.pl )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bn/asm/modexp512-x86_64.pl )
endif ( )

# crypto/rsa
set ( ${PROJECT_NAME}_CRYPTO_RSA_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_eay.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_gen.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_sign.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_saos.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_pk1.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_ssl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_none.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_oaep.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_chk.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_null.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_pss.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_x931.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_asn1.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_depr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_ameth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_prn.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_pmeth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rsa/rsa_crpt.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_RSA_SRC} )
source_group ( "crypto_rsa" FILES ${${PROJECT_NAME}_CRYPTO_RSA_SRC} )

# crypto/dsa
set ( ${PROJECT_NAME}_CRYPTO_DSA_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dsa/dsa_gen.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dsa/dsa_key.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dsa/dsa_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dsa/dsa_asn1.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dsa/dsa_vrf.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dsa/dsa_sign.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dsa/dsa_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dsa/dsa_ossl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dsa/dsa_depr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dsa/dsa_ameth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dsa/dsa_pmeth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dsa/dsa_prn.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_DSA_SRC} )
source_group ( "crypto_dsa" FILES ${${PROJECT_NAME}_CRYPTO_DSA_SRC} )

# crypto/dso
set ( ${PROJECT_NAME}_CRYPTO_DSO_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dso/dso_dl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dso/dso_dlfcn.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dso/dso_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dso/dso_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dso/dso_null.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dso/dso_openssl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dso/dso_win32.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dso/dso_vms.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dso/dso_beos.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_DSO_SRC} )
source_group ( "crypto_dso" FILES ${${PROJECT_NAME}_CRYPTO_DSO_SRC} )

# crypto/dh
set ( ${PROJECT_NAME}_CRYPTO_DH_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dh/dh_asn1.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dh/dh_gen.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dh/dh_key.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dh/dh_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dh/dh_check.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dh/dh_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dh/dh_depr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dh/dh_ameth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dh/dh_pmeth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/dh/dh_prn.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_DH_SRC} )
source_group ( "crypto_dh" FILES ${${PROJECT_NAME}_CRYPTO_DH_SRC} )

# crypto/ec
set ( ${PROJECT_NAME}_CRYPTO_EC_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ecp_smpl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ecp_mont.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ecp_nist.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec_cvt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec_mult.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec_curve.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec_check.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec_print.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec_asn1.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec_key.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec2_smpl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec2_mult.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec_ameth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec_pmeth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/eck_prn.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ecp_nistp224.c
        # ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ecp_nistp256.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ecp_nistp521.c
        # ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ecp_nistputil.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ecp_oct.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec2_oct.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ec/ec_oct.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_EC_SRC} )
source_group ( "crypto_ec" FILES ${${PROJECT_NAME}_CRYPTO_EC_SRC} )


# crypto/ecdh
set ( ${PROJECT_NAME}_CRYPTO_ECDH_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ecdh/ech_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ecdh/ech_ossl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ecdh/ech_key.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ecdh/ech_err.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_ECDH_SRC} )
source_group ( "crypto_ecdh" FILES ${${PROJECT_NAME}_CRYPTO_ECDH_SRC} )

# crypto/ecdsa
set ( ${PROJECT_NAME}_CRYPTO_ECDSA_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ecdsa/ecs_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ecdsa/ecs_asn1.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ecdsa/ecs_ossl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ecdsa/ecs_sign.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ecdsa/ecs_vrf.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ecdsa/ecs_err.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_ECDSA_SRC} )
source_group ( "crypto_ecdsa" FILES ${${PROJECT_NAME}_CRYPTO_ECDSA_SRC} )

# crypto/buffer
set ( ${PROJECT_NAME}_CRYPTO_BUFFER_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/buffer/buffer.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/buffer/buf_str.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/buffer/buf_err.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_BUFFER_SRC} )
source_group ( "crypto_buffer" FILES ${${PROJECT_NAME}_CRYPTO_BUFFER_SRC} )

# crypto/bio
set ( ${PROJECT_NAME}_CRYPTO_BIO_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bio_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bio_cb.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bio_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bss_mem.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bss_null.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bss_fd.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bss_file.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bss_sock.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bss_conn.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bf_null.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bf_buff.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/b_print.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/b_dump.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/b_sock.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bss_acpt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bf_nbio.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bss_log.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bss_bio.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/bio/bss_dgram.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_BIO_SRC} )
source_group ( "crypto_bio" FILES ${${PROJECT_NAME}_CRYPTO_BIO_SRC} )

# crypto/stack
set ( ${PROJECT_NAME}_CRYPTO_STACK_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/stack/stack.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_STACK_SRC} )
source_group ( "crypto_stack" FILES ${${PROJECT_NAME}_CRYPTO_STACK_SRC} )

# crypto/lhash
set ( ${PROJECT_NAME}_CRYPTO_LHASH_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/lhash/lhash.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/lhash/lh_stats.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_LHASH_SRC} )
source_group ( "crypto_lhash" FILES ${${PROJECT_NAME}_CRYPTO_LHASH_SRC} )

# crypto/rand
set ( ${PROJECT_NAME}_CRYPTO_RAND_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rand/md_rand.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rand/randfile.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rand/rand_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rand/rand_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rand/rand_egd.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rand/rand_win.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rand/rand_unix.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rand/rand_os2.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/rand/rand_nw.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_RAND_SRC} )
source_group ( "crypto_rand" FILES ${${PROJECT_NAME}_CRYPTO_RAND_SRC} )

# crypto/err
set ( ${PROJECT_NAME}_CRYPTO_ERR_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/err/err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/err/err_all.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/err/err_prn.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_ERR_SRC} )
source_group ( "crypto_err" FILES ${${PROJECT_NAME}_CRYPTO_ERR_SRC} )

# crypto/objects
set ( ${PROJECT_NAME}_CRYPTO_OBJECTS_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/objects/o_names.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/objects/obj_dat.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/objects/obj_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/objects/obj_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/objects/obj_xref.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_OBJECTS_SRC} )
source_group ( "crypto_objects" FILES ${${PROJECT_NAME}_CRYPTO_OBJECTS_SRC} )

# crypto/evp
set ( ${PROJECT_NAME}_CRYPTO_EVP_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/encode.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/digest.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/evp_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/evp_key.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/evp_acnf.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/evp_cnf.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_des.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_bf.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_idea.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_des3.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_camellia.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_rc4.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_aes.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/names.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_seed.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_xcbc_d.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_rc2.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_cast.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_rc5.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/m_null.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/m_md4.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/m_md5.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/m_sha.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/m_sha1.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/m_wp.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/m_dss.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/m_dss1.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/m_ripemd.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/m_ecdsa.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/p_open.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/p_seal.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/p_sign.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/p_verify.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/p_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/p_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/p_dec.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/bio_md.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/bio_b64.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/bio_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/evp_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_null.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/c_all.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/c_allc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/c_alld.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/evp_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/bio_ok.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/evp_pkey.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/evp_pbe.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/p5_crpt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/p5_crpt2.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_old.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/pmeth_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/pmeth_fn.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/pmeth_gn.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/m_sigver.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_aes_cbc_hmac_sha1.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/evp/e_rc4_hmac_md5.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_EVP_SRC} )
source_group ( "crypto_evp" FILES ${${PROJECT_NAME}_CRYPTO_EVP_SRC} )

# crypto/asn1
set ( ${PROJECT_NAME}_CRYPTO_ASN1_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_object.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_bitstr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_utctm.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_gentm.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_time.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_int.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_octet.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_print.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_type.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_set.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_dup.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_d2i_fp.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_i2d_fp.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_enum.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_utf8.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_sign.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_digest.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_verify.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_mbstr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_strex.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_algor.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_val.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_pubkey.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_sig.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_req.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_attrib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_bignum.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_long.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_name.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_x509.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_x509a.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_crl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_info.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_spki.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/nsseq.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_nx509.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/d2i_pu.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/d2i_pr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/i2d_pu.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/i2d_pr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/t_req.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/t_x509.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/t_x509a.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/t_crl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/t_pkey.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/t_spki.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/t_bitst.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/tasn_new.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/tasn_fre.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/tasn_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/tasn_dec.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/tasn_utl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/tasn_typ.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/tasn_prn.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/ameth_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/f_int.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/f_string.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/n_pkey.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/f_enum.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_pkey.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_bool.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/x_exten.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/bio_asn1.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/bio_ndef.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/asn_mime.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/asn1_gen.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/asn1_par.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/asn1_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/asn1_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_bytes.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/a_strnid.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/evp_asn1.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/asn_pack.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/p5_pbe.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/p5_pbev2.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/p8_pkey.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/asn1/asn_moid.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_ASN1_SRC} )
source_group ( "crypto_asn1" FILES ${${PROJECT_NAME}_CRYPTO_ASN1_SRC} )

# crypto/pem
set ( ${PROJECT_NAME}_CRYPTO_PEM_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pem/pem_sign.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pem/pem_seal.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pem/pem_info.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pem/pem_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pem/pem_all.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pem/pem_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pem/pem_x509.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pem/pem_xaux.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pem/pem_oth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pem/pem_pk8.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pem/pem_pkey.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pem/pvkfmt.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_PEM_SRC} )
source_group ( "crypto_pem" FILES ${${PROJECT_NAME}_CRYPTO_PEM_SRC} )

# crypto/x509
set ( ${PROJECT_NAME}_CRYPTO_X509_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_def.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_d2.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_r2x.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_cmp.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_obj.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_req.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509spki.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_vfy.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_set.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509cset.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509rset.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509name.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_v3.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_ext.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_att.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509type.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_lu.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x_all.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_txt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_trs.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/by_file.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/by_dir.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509/x509_vpm.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_X509_SRC} )
source_group ( "crypto_x509" FILES ${${PROJECT_NAME}_CRYPTO_X509_SRC} )

# crypto/x509v3
set ( ${PROJECT_NAME}_CRYPTO_X509V3_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_bcons.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_bitst.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_conf.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_extku.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_ia5.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_prn.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_utl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_genn.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_alt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_skey.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_akey.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_pku.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_int.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_enum.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_sxnet.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_cpols.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_crld.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_purp.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_info.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_ocsp.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_akeya.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_pmaps.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_pcons.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_ncons.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_pcia.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_pci.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/pcy_cache.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/pcy_node.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/pcy_data.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/pcy_map.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/pcy_tree.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/pcy_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_asid.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/x509v3/v3_addr.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_X509V3_SRC} )
source_group ( "crypto_x509v3" FILES ${${PROJECT_NAME}_CRYPTO_X509V3_SRC} )

# crypto/cms
set ( ${PROJECT_NAME}_CRYPTO_CMS_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cms/cms_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cms/cms_asn1.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cms/cms_att.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cms/cms_io.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cms/cms_smime.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cms/cms_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cms/cms_sd.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cms/cms_dd.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cms/cms_cd.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cms/cms_env.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cms/cms_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cms/cms_ess.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/cms/cms_pwri.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_CMS_SRC} )
source_group ( "crypto_cms" FILES ${${PROJECT_NAME}_CRYPTO_CMS_SRC} )

# crypto/conf
set ( ${PROJECT_NAME}_CRYPTO_CONF_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/conf/conf_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/conf/conf_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/conf/conf_api.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/conf/conf_def.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/conf/conf_mod.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/conf/conf_mall.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/conf/conf_sap.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_CONF_SRC} )
source_group ( "crypto_conf" FILES ${${PROJECT_NAME}_CRYPTO_CONF_SRC} )

# crypto/txt_db
set ( ${PROJECT_NAME}_CRYPTO_TXTDB_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/txt_db/txt_db.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_TXTDB_SRC} )
source_group ( "crypto_txtdb" FILES ${${PROJECT_NAME}_CRYPTO_TXTDB_SRC} )

# crypto/pkcs7
set ( ${PROJECT_NAME}_CRYPTO_PKCS7_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs7/pk7_asn1.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs7/pk7_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs7/pkcs7err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs7/pk7_doit.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs7/pk7_smime.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs7/pk7_attr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs7/pk7_mime.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs7/bio_pk7.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_PKCS7_SRC} )
source_group ( "crypto_pkcs7" FILES ${${PROJECT_NAME}_CRYPTO_PKCS7_SRC} )

# crypto/pkcs12
set ( ${PROJECT_NAME}_CRYPTO_PKCS12_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/p12_add.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/p12_asn.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/p12_attr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/p12_crpt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/p12_crt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/p12_decr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/p12_init.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/p12_key.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/p12_kiss.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/p12_mutl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/p12_utl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/p12_npas.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/pk12err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/p12_p8d.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pkcs12/p12_p8e.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_PKCS12_SRC} )
source_group ( "crypto_pkcs12" FILES ${${PROJECT_NAME}_CRYPTO_PKCS12_SRC} )

# crypto/comp
set ( ${PROJECT_NAME}_CRYPTO_COMP_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/comp/comp_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/comp/comp_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/comp/c_rle.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/comp/c_zlib.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_COMP_SRC} )
source_group ( "crypto_comp" FILES ${${PROJECT_NAME}_CRYPTO_COMP_SRC} )

# crypto/engine
set ( ${PROJECT_NAME}_CRYPTO_ENGINE_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/eng_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/eng_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/eng_list.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/eng_init.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/eng_ctrl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/eng_table.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/eng_pkey.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/eng_fat.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/eng_all.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/tb_rsa.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/tb_dsa.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/tb_ecdsa.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/tb_dh.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/tb_ecdh.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/tb_rand.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/tb_store.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/tb_cipher.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/tb_digest.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/tb_pkmeth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/tb_asnmth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/eng_openssl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/eng_cnf.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/eng_dyn.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/eng_cryptodev.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/eng_rsax.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/engine/eng_rdrand.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_ENGINE_SRC} )
source_group ( "crypto_engine" FILES ${${PROJECT_NAME}_CRYPTO_ENGINE_SRC} )

# crypto/ocsp
set ( ${PROJECT_NAME}_CRYPTO_OCSP_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ocsp/ocsp_asn.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ocsp/ocsp_ext.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ocsp/ocsp_ht.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ocsp/ocsp_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ocsp/ocsp_cl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ocsp/ocsp_srv.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ocsp/ocsp_prn.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ocsp/ocsp_vfy.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ocsp/ocsp_err.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_OCSP_SRC} )
source_group ( "crypto_ocsp" FILES ${${PROJECT_NAME}_CRYPTO_OCSP_SRC} )

# crypto/ui
set ( ${PROJECT_NAME}_CRYPTO_UI_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ui/ui_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ui/ui_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ui/ui_openssl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ui/ui_util.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ui/ui_compat.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_UI_SRC} )
source_group ( "crypto_ui" FILES ${${PROJECT_NAME}_CRYPTO_UI_SRC} )

# crypto/krb5
set ( ${PROJECT_NAME}_CRYPTO_KRB5_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/krb5/krb5_asn.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_KRB5_SRC} )
source_group ( "crypto_krb5" FILES ${${PROJECT_NAME}_CRYPTO_KRB5_SRC} )

# crypto/pqueue
set ( ${PROJECT_NAME}_CRYPTO_PQUEUE_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/pqueue/pqueue.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_PQUEUE_SRC} )
source_group ( "crypto_pqueue" FILES ${${PROJECT_NAME}_CRYPTO_PQUEUE_SRC} )

# crypto/whrlpool
set ( ${PROJECT_NAME}_CRYPTO_WHRLPOOL_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/whrlpool/wp_dgst.c )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_[^_]+" )
    list ( APPEND ${PROJECT_NAME}_CRYPTO_WHRLPOOL_SRC
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/whrlpool/wp_block.c )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "android_[^_]+_gcc" )
    list ( APPEND ${PROJECT_NAME}_CRYPTO_WHRLPOOL_SRC
            ${${PROJECT_NAME}_SOURCE_DIR}/crypto/whrlpool/wp_block.c )
endif ( ) 
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_WHRLPOOL_SRC} )
source_group ( "crypto_whrlpool" FILES ${${PROJECT_NAME}_CRYPTO_WHRLPOOL_SRC} )
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/whrlpool/asm/wp-mmx.pl )
elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "[^_]+_amd64_[^_]+" )
    openssl_asm_compile ( ${${PROJECT_NAME}_SOURCE_DIR}/crypto/whrlpool/asm/wp-x86_64.pl )
endif ( )

# crypto/ts
set ( ${PROJECT_NAME}_CRYPTO_TS_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ts/ts_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ts/ts_req_utils.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ts/ts_req_print.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ts/ts_rsp_utils.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ts/ts_rsp_print.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ts/ts_rsp_sign.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ts/ts_rsp_verify.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ts/ts_verify_ctx.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ts/ts_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ts/ts_conf.c
        ${${PROJECT_NAME}_SOURCE_DIR}/crypto/ts/ts_asn1.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_CRYPTO_TS_SRC} )
source_group ( "crypto_ts" FILES ${${PROJECT_NAME}_CRYPTO_TS_SRC} )

# engines
set ( ${PROJECT_NAME}_ENGINES_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/engines/e_4758cca.c
        ${${PROJECT_NAME}_SOURCE_DIR}/engines/e_aep.c
        ${${PROJECT_NAME}_SOURCE_DIR}/engines/e_atalla.c
        ${${PROJECT_NAME}_SOURCE_DIR}/engines/e_cswift.c
        ${${PROJECT_NAME}_SOURCE_DIR}/engines/e_gmp.c
        ${${PROJECT_NAME}_SOURCE_DIR}/engines/e_chil.c
        ${${PROJECT_NAME}_SOURCE_DIR}/engines/e_nuron.c
        ${${PROJECT_NAME}_SOURCE_DIR}/engines/e_sureware.c
        ${${PROJECT_NAME}_SOURCE_DIR}/engines/e_ubsec.c
        ${${PROJECT_NAME}_SOURCE_DIR}/engines/e_padlock.c
        ${${PROJECT_NAME}_SOURCE_DIR}/engines/e_capi.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_ENGINES_SRC} )
source_group ( "engines" FILES ${${PROJECT_NAME}_ENGINES_SRC} )

# ssl
set ( ${PROJECT_NAME}_SSL_SRC 
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s2_meth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s2_srvr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s2_clnt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s2_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s2_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s2_pkt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s3_meth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s3_srvr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s3_clnt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s3_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s3_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s3_pkt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s3_both.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s3_cbc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s23_meth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s23_srvr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s23_clnt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s23_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/s23_pkt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/t1_meth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/t1_srvr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/t1_clnt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/t1_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/t1_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/d1_meth.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/d1_srvr.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/d1_clnt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/d1_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/d1_pkt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/d1_both.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/d1_enc.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/d1_srtp.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl_lib.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl_err2.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl_cert.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl_sess.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl_ciph.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl_stat.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl_rsa.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl_asn1.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl_txt.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl_algs.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/bio_ssl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/ssl_err.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/kssl.c
        ${${PROJECT_NAME}_SOURCE_DIR}/ssl/t1_reneg.c )
list ( APPEND ${PROJECT_NAME}_SRC ${${PROJECT_NAME}_SSL_SRC} )
source_group ( "ssl" FILES ${${PROJECT_NAME}_SSL_SRC} )

# library
add_library ( ${PROJECT_NAME} STATIC 
        ${${PROJECT_NAME}_SRC} 
        ${${PROJECT_NAME}_ASMOBJ} )
target_include_directories ( ${PROJECT_NAME} BEFORE PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}/include
    ${CMAKE_CURRENT_BINARY_DIR}/include_private )
target_compile_definitions ( ${PROJECT_NAME} PRIVATE ${${PROJECT_NAME}_DEFINITIONS} )
add_custom_target ( ${PROJECT_NAME}_asm DEPENDS ${${PROJECT_NAME}_ASMOBJ} )
add_dependencies ( ${PROJECT_NAME} ${PROJECT_NAME}_asm )

