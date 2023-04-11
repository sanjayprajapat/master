<aura:application extends="force:slds" >
    <c:CustomLookUp objectName="Contact" 
                    fieldName="LastName" 
                    Label="Enter Contact LastName" 
                    iconName="action:new_account"
                    recordDisplaySize="5"
                    placeholder="Enter At Least 2 Character to Search"
                    />
</aura:application>