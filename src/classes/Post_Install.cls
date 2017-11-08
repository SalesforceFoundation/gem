
global with sharing class Post_Install {

    global void onInstall(InstallContext context) {
        glue();
    }

    global void glue() {
        // The install script needs to use the Glue class instead going through the TDTM_API class because both the
        // NPSP and HEDA Trigger Handler tables may already have custom TDTM records, or modifications of each package's
        // records, that we don't want to lose.
        Glue glue = new Glue();
        glue.tdtmTransfer();
    }
}