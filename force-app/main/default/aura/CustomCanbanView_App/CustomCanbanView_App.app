<aura:application extends="force:slds">
	<c:CustomCanbanView objName="Opportunity" 
                   		objFields="['Name', 'AccountId', 'Account.Name', 'CloseDate', 'StageName', 'Amount']" 
                   		kanbanPicklistField="StageName"/>
</aura:application>