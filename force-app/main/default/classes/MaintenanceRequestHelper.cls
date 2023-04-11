public class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(){
        Map<Id, Case> mantnceReqToEvaluate = new Map<Id, Case>();
        for(Case mantnceReq : (List<Case>)Trigger.new){
            if((mantnceReq.Type.contains('Repair') || mantnceReq.Type.contains('Routine Maintenance')) && mantnceReq.Status == 'Closed'){
                mantnceReqToEvaluate.put(mantnceReq.Id,mantnceReq);
            }
        }
        
        Map<Id, decimal> mapOfProdIdWithMaintenanceCycle = getMapOfProdIdWithMaintenanceCycle();
        
        List<Case> lstOfMaintenanceRoutines = getListOfMaintenanceRoutineList(mantnceReqToEvaluate, mapOfProdIdWithMaintenanceCycle);

        System.debug('lstOfMaintenanceRoutines :::::::: '+lstOfMaintenanceRoutines);
        if(lstOfMaintenanceRoutines != null && lstOfMaintenanceRoutines.size() > 0)
            INSERT lstOfMaintenanceRoutines;
    }
    
    private static Map<Id, decimal> getMapOfProdIdWithMaintenanceCycle(){
        Map<Id,decimal> mapOfProdIdWithMaintenanceCycle = new Map<Id, decimal>();
        for(Product2 prod : [SELECT Id, Maintenance_Cycle__c from Product2]){
            mapOfProdIdWithMaintenanceCycle.put(prod.Id, prod.Maintenance_Cycle__c);
        }
        
        return mapOfProdIdWithMaintenanceCycle;
    }
    
    private static List<Case> getListOfMaintenanceRoutineList(Map<Id, Case> mantnceReqToEvaluate, Map<Id, decimal> mapOfProdIdWithMaintenanceCycle){
        List<Case> lstOfMaintenanceRoutines = new List<Case>();
        
        for(Case maintenance : mantnceReqToEvaluate.values()){
            Case maintenanceNewIns = new Case();
            maintenanceNewIns.Vehicle__c = maintenance.Vehicle__c;
            maintenanceNewIns.Equipment__c = maintenance.Equipment__c;
            maintenanceNewIns.Type = 'Routine Maintenance';
            maintenanceNewIns.Subject = 'Your Routine Maintenance Schedule';
            maintenanceNewIns.Date_Reported__c = Date.today();
            maintenanceNewIns.Date_Due__c = getDueDate(maintenance, mapOfProdIdWithMaintenanceCycle);
            
            maintenanceNewIns.Status = 'New';
            maintenanceNewIns.Origin = 'Phone';
        
            lstOfMaintenanceRoutines.add(maintenanceNewIns);
        }
        return lstOfMaintenanceRoutines;    
    }
    
    private static Date getDueDate(Case maintenance, Map<Id, decimal> mapOfProdIdWithMaintenanceCycle){
        Date dt = null;
        if (mapOfProdIdWithMaintenanceCycle.get(maintenance.Equipment__c) != null) {
            dt = Date.today().addDays(Integer.valueOf(mapOfProdIdWithMaintenanceCycle.get(maintenance.Equipment__c)));
        }
        
        return dt;
    }
}