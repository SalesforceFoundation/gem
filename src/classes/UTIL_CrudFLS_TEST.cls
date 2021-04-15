/*
    © 2019, Salesforce.org.
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
* @date 2018
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
* @description Test class which holds negative tests for Util_CrudFLS.
* Positive cases have coverage in GiftEntryFormController_TEST as a side effect of using that class.
*/
@isTest
private with sharing class UTIL_CrudFLS_TEST {
    private static final String RO_USER_NAME = 'adv_readonly_tester@sfdodevs.org';
    private static final String LEAD_LASTNAME = 'testLead';
    private static final String PROFILE_MINIMUM_ACCESS = 'Minimum Access - Salesforce';

    @testSetup
    private static void setup() {
        UTIL_UnitTestData_TEST.createNewUserWithProfile(RO_USER_NAME, PROFILE_MINIMUM_ACCESS);
        Lead ld = new Lead(LastName = LEAD_LASTNAME, Company = 'Test');
        insert ld;
    }

    @isTest
    private static void testCheckUpsertNegative() {
        User u = [SELECT Id FROM User WHERE Username = :RO_USER_NAME LIMIT 1];
        Lead ld = [SELECT Id, LastName, Company FROM Lead WHERE LastName = :LEAD_LASTNAME];

        System.runAs(u) {
            Boolean exceptionCaught = false;
            try {
                UTIL_CrudFLS.checkUpsert(ld);
            } catch(UTIL_CrudFLS.AccessException ex) {
                exceptionCaught = true;
                System.assert(ex.getMessage().contains('insert access required. Object: Lead'), 'Expected to catch insert exception for Lead object');
            }
            System.assert(exceptionCaught, 'No exception caught.');
        }
    }

    @isTest
    private static void testCheckUpdateNegative() {
        User u = [SELECT Id FROM User WHERE Username = :RO_USER_NAME LIMIT 1];

        System.runAs(u) {
            Boolean exceptionCaught = false;
            try {
                UTIL_CrudFLS.checkAccess(UTIL_CrudFLS.CRUD_OPERATION.MODIFY, 'Lead', new List<String>{'LastName'});
            } catch(UTIL_CrudFLS.AccessException ex) {
                exceptionCaught = true;
                System.assert(ex.getMessage().contains('update access required. Object: Lead'), 'Expected to catch insert exception for Lead object');
            }
            System.assert(exceptionCaught, 'No exception caught.');
        }
    }

    @isTest
    private static void testCreateNegative() {
        User u = [SELECT Id FROM User WHERE Username = :RO_USER_NAME LIMIT 1];

        System.runAs(u) {
            Boolean exceptionCaught = false;
            try {
                UTIL_CrudFLS.create(new Lead(LastName = 'Test', Company = 'Test'));
            } catch(UTIL_CrudFLS.AccessException ex) {
                exceptionCaught = true;
                System.assert(ex.getMessage().contains('insert access required. Object: Lead'), 'Expected to catch insert exception for Lead object');
            }
            System.assert(exceptionCaught, 'No exception caught.');
        }
    }

    @isTest
    private static void testDeleteNegative() {
        User u = [SELECT Id FROM User WHERE Username = :RO_USER_NAME LIMIT 1];
        Lead ld = [SELECT Id, LastName, Company FROM Lead WHERE LastName = :LEAD_LASTNAME];

        System.runAs(u) {
            Boolean exceptionCaught = false;
            try {
                UTIL_CrudFLS.del(new List<Lead>{ld}, true);
            } catch(UTIL_CrudFLS.AccessException ex) {
                exceptionCaught = true;
                System.assert(ex.getMessage().contains('delete access required. Object: Lead'), 'Expected to catch insert exception for Lead object');
            }
            System.assert(exceptionCaught, 'No exception caught.');
        }
    }
}