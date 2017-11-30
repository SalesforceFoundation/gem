global with sharing class Post_Install_Script {

    global void onInstall(InstallContext context) {
        glue();
    }

    // @TODO Should we have a setting that tells us whether the Advancement pos-install script failed? If so, each
    // @TODO Trigger Handler dispatcher could re-try the merge or TDTM records.

    global void glue() {
        // The install script needs to use the Glue class instead going through the TDTM API class because both the
        // NPSP and HEDA Trigger Handler tables may already have custom TDTM records, or modifications of each package's
        // records, that we don't want to lose.
        TDTM_Glue glue = new TDTM_Glue();
        glue.combineTdtmConfig();

        //Activate usage of the Advancement TDTM configuration
        Adv_Settings__c settings = [select use_adv__c from Adv_Settings__c limit 1];
        settings.use_adv__c = true;
        upsert settings;
    }
}