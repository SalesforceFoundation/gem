/*
    Copyright (c) 2017, Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2017
* @group
* @group-content
* @description Constants and helper methods used for common settings in npe01: account model, default contact role, etc.
**/
public with sharing class Adv_Constants {

    /*******************************************************************************************************
    * @description One-to-One org type value
    */
    public static final String ONE_TO_ONE_ORGANIZATION_TYPE = 'One-to-One Individual';

    /*******************************************************************************************************
    * @description Individual Bucket value for system processor field
    */
    public static final String BUCKET_PROCESSOR = 'Individual';

    /*******************************************************************************************************
    * @description Individual Bucket Account name
    */
    public static String BUCKET_ACCOUNT_NAME = 'Individual';

    /*******************************************************************************************************
    * @description Household Account value for system processor field
    */
    public static final String HH_ACCOUNT_PROCESSOR = 'Household Account';

    /*******************************************************************************************************
    * @description Household Account org type value
    */
    public static final String HH_ACCOUNT_TYPE = 'Household Account';

    /*******************************************************************************************************
    * @description Household Account value for the standard Type field
    */
    public static final string HH_TYPE = 'Household';


    /*******************************************************************************************************
    * @description Returns whether we are in the Individual Bucket Account Model
    * @return  boolean
    */
    public static boolean isBucketModel() {
        return (npsp3c.UTIL_CustomSettings_API.getContactsSettings().npe01__Account_Processor__c == BUCKET_PROCESSOR);
    }

    /*******************************************************************************************************
    * @description Returns whether we are in the Household Account Model
    * @return  boolean
    */
    public static boolean isHHAccountModel() {
        return (npsp3c.UTIL_CustomSettings_API.getContactsSettings().npe01__Account_Processor__c == HH_ACCOUNT_PROCESSOR);
    }
}