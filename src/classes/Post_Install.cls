
global with sharing class Post_Install {

    global void onInstall(InstallContext context) {
        glue();
    }

    global void glue() {
        Glue glue = new Glue();
        glue.tdtmTransfer();
        glue.tdtmDeduplicate();
    }
}