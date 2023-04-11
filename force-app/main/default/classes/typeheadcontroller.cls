public class typeheadcontroller {    
    // AutoCompleteController.cls    
    // Instance fields
    public String searchTerm {get; set;}
    public String selectedMovie {get; set;}
    
    // JS Remoting action called when searching for a movie name
    @RemoteAction
    public static List<Account> searchMovie(String searchTerm) {
        System.debug('Movie Name is: '+searchTerm );
        List<Account> movies = Database.query('Select Id, Name from Account where name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        return movies;
    }
}