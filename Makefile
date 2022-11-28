# Get directory of this makefile
MAKEFILE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# Specify the default makedefs file, which can be overridden at the command line
MAKEDEFS = $(MAKEFILE_DIR)makedefs
include $(MAKEDEFS)

DEMO_SRC_PATH = $(QUECTEL_SDK)/quectel/example
OUTPUT_PATH = $(MAKEFILE_DIR)out/bin

DAM_CPPFLAGS = -DQAPI_TXM_MODULE -DTXM_MODULE -DTX_DAM_QC_CUSTOMIZATIONS -DTX_ENABLE_PROFILING -DTX_ENABLE_EVENT_TRACE -DTX_DISABLE_NOTIFY_CALLBACKS -DFX_FILEX_PRESENT -DTX_ENABLE_IRQ_NESTING -DTX3_CHANGES -DAZQ_APP_START_DELAY=10 -DAZQ_LOG_ENABLE -DAZQ_LOG_ENABLE_COLOURS -DAZQ_LOG_LEVEL=AZQ_LOG_LEVEL_TRACE -DLOG_CHANNEL=AZQ_LOG_TO_UART_2
DAM_CFLAGS = -marm -target armv7m-none-musleabi -mfloat-abi=softfp -mfpu=none -mcpu=cortex-a7 -mno-unaligned-access  -fms-extensions -Osize -fshort-enums -fsigned-char -Wbuiltin-macro-redefined 
DAM_INCLUDE_PATH = -I$(COMPILER_INCL) -I$(QUECTEL_SDK)/include/qapi -I$(QUECTEL_SDK)/include/threadx_api -I$(QUECTEL_SDK)/include/stringl -I$(QUECTEL_SDK)/quectel/utils/include -I$(MAKEFILE_DIR)/hdr

# Always builds phony rules
.PHONY: all clean doc

# Builds libazq_quectel.lib
all :
	@ test -d $(OUTPUT_PATH) || mkdir -p $(OUTPUT_PATH)
	@ rm -f $(OUTPUT_PATH)/libparson.lib
	@ rm -f $(OUTPUT_PATH)/*.o
	@ rm -f $(OUTPUT_PATH)/*.S
	$(COMPILER_C_TOOL) --version
	@ echo Compile parson.c
	@ $(COMPILER_C_TOOL) -c  $(DAM_CPPFLAGS) $(DAM_CFLAGS) $(DAM_INCLUDE_PATH) $(MAKEFILE_DIR)/parson.c -o $(OUTPUT_PATH)/parson.o
	
	@ echo Archive libparson.lib
	$(ARCHIVER_TOOL) rcs $(OUTPUT_PATH)/libparson.lib \
							$(OUTPUT_PATH)/parson.o 
	@ rm -fR $(OUTPUT_PATH)/*.o

	@ echo Copy library to SDK folder
	@ cp -f	$(OUTPUT_PATH)/libparson.lib $(QUECTEL_SDK)/libs/llvm/libparson.lib 
	@ test -d $(QUECTEL_SDK)/include/parson || mkdir -p $(QUECTEL_SDK)/include/parson
	@ rm -fR $(QUECTEL_SDK)/include/parson/*.*
	@ cp $(MAKEFILE_DIR)/parson.h $(QUECTEL_SDK)/include/parson
	
# Deletes previous output and temporary files
clean :
	@ rm -f $(OUTPUT_PATH)/*.S
	@ rm -fR $(OUTPUT_PATH)/*.o
	@ rm -fR $(OUTPUT_PATH)/*.lib
	@ rm -fR $(MAKEFILE_DIR)out/Documentation/*.*

# Generates documentation
doc :
	@ rm -fR $(MAKEFILE_DIR)out/Documentation/*.*
	doxygen 