
global with sharing class PostInstallScript {

    global void onInstall(InstallContext context) {
        glue();
    }

    // @TODO Should we have a setting that tells us whether the Advancement pos-install script failed? If so, each
    // @TODO Trigger Handler dispatcher could re-try the merge or TDTM records.

    global void glue() {
        // The install script needs to use the Glue class instead going through the TDTM API class because both the
        // NPSP and HEDA Trigger Handler tables may already have custom TDTM records, or modifications of each package's
        // records, that we don't want to lose.
        TdtmGlue glue = new TdtmGlue();
        glue.combineTdtmConfig();
    }
}