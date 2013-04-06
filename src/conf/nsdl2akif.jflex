package gr.agroknow.metadata.transformer.nsdl2akif;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.List;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

import net.zettadata.generator.tools.NSDLAgeRange;
import net.zettadata.generator.tools.NSDLlreLRT;
import net.zettadata.generator.tools.Toolbox;
import net.zettadata.generator.tools.ToolboxException;

%%
%class NSDL2AKIF
%standalone
%unicode

%{

	private NSDLAgeRange nsdlAge = new NSDLAgeRange() ;
	private List<String> keywords = new ArrayList<String>() ;
	private Set<String> endUsers = new HashSet<String>() ;
	private NSDLlreLRT lrt = new NSDLlreLRT() ;
	private JSONArray contexts = new JSONArray() ;
	private String url ;
	private String title ;
	private String description ;
	private String language ;
	private String rights ;
	private String format ;
	private String creationDate ;
	private String author ;
	private String licensor ;

    private JSONObject akif ;
    
    public void generate()
    {
    	generateLanguageBlock() ;
    	generateTokenBlock() ;
    	generateRights() ;
    	generateContributors() ;
    	generateExpressions() ;
    }
    
    @SuppressWarnings("unchecked")
    private void generateExpressions()
    {
    	JSONArray expressions = (JSONArray) akif.get( "expressions" ) ;
    	JSONObject expression = new JSONObject() ;
    	if ( language != null )
    	{
    		expression.put( "language", language ) ;
    	}
    	StringBuilder manifestationsString = new StringBuilder() ;
    	manifestationsString.append( "[{\"name\": \"experience\", " ) ;
    	if ( format != null )
    	{
    		manifestationsString.append( "\"parameter\": \"" + format + "\"," ) ;
    	}
    	manifestationsString.append( " \"items\": [{ \"url\": \"" + url + "\", \"broken\": false}]}]" ) ;  	
      	expression.put( "manifestations", JSONValue.parse( manifestationsString.toString() ) ) ;
    	expressions.add( expression ) ;
    	akif.put( "expressions", expressions ) ;
    }
    
    @SuppressWarnings("unchecked")
    private void generateContributors()
    {
    	JSONArray contributors = (JSONArray)akif.get( "contributors" ) ;
    	if ( author != null )
    	{
    		JSONObject auth = new JSONObject() ;
    		auth.put( "role", "author" ) ;
    		auth.put( "name", author ) ;
    		if ( creationDate != null )
    		{
    			auth.put( "date", creationDate ) ;
    		}
    		contributors.add( auth ) ;
    	}
    	if ( licensor != null )
    	{
    		JSONObject lic = new JSONObject() ;
    		lic.put( "role", "licensor" ) ;
    		lic.put( "name", licensor ) ;
    		contributors.add( lic ) ;
    	}
    	akif.put("contributors", contributors ) ;
    }
    
    @SuppressWarnings("unchecked")
    private void generateRights()
    {
    	JSONObject r = (JSONObject) akif.get( "rights" ) ;
    	if (rights != null)
    	{
    		JSONObject description = new JSONObject() ;
    		description.put( "en", rights ) ;
    		r.put( "description", description ) ;    		
    	}
    	akif.put( "rights", r ) ;
    }
    
    @SuppressWarnings("unchecked")
    private void generateTokenBlock()
    {
    	JSONObject tokenBlock = (JSONObject) akif.get( "tokenBlock" ) ;
    	if ( !lrt.getLearningResourceTypes().isEmpty() )
    	{
    		JSONArray learningResourceTypes = new JSONArray() ;
			learningResourceTypes.addAll( lrt.getLearningResourceTypes() ) ;
    		tokenBlock.put("learningResourceTypes", learningResourceTypes) ;
    	}
    	if ( !"0-0".equals( nsdlAge.getAgeRange() ) )
    	{
    		tokenBlock.put( "ageRange", nsdlAge.getAgeRange() ) ;
    		
    		//18 and under = compulsory education
			//18 - U = higher education
			String[] age = nsdlAge.getAgeRange().split( "-" ) ;
    		if ("U".equals( age[1] ))
    		{
    			contexts.add( "higher education" ) ;
    		}
    		else
    		{	
    			int max = Integer.parseInt( age[1] ) ;
    			if ( max > 18 )
    			{
    				contexts.add( "higher education" ) ;
    			}
    		}
    		if ("U".equals( age[0] ))
    		{
    			contexts.add( "compulsory education" ) ;
    		}
    		else
    		{
    			int min = Integer.parseInt( age[0] ) ;
    			if ( min < 18 )
    			{
					contexts.add( "compulsory education" ) ;
				}
			}
    		tokenBlock.put( "contexts", contexts ) ;
    		
    	}
    	if ( !endUsers.isEmpty() )
    	{
    		JSONArray endUserRoles = new JSONArray() ;
    		endUserRoles.addAll( endUsers ) ;
    		tokenBlock.put( "endUserRoles", endUserRoles ) ;
    	}
    	akif.put( "tokenBlock", tokenBlock ) ;
    }
	
	@SuppressWarnings("unchecked")
    private void generateLanguageBlock()
    {
    	JSONObject languageBlocks = (JSONObject) akif.get( "languageBlocks" ) ;
    	JSONObject enBlock = new JSONObject() ;
    	if (title != null)
    	{
    		enBlock.put( "title", title ) ;
    	}
    	if (description != null)
    	{
    		enBlock.put( "description", description ) ;
    	}
    	if ( !keywords.isEmpty() )
    	{
    		JSONArray kws = new JSONArray() ;
    		kws.addAll( keywords ) ;
    		enBlock.put( "keywords", kws ) ;
    	}
    	languageBlocks.put( "en", enBlock ) ;
    	akif.put( "languageBlocks", languageBlocks ) ;
    }

    public String toString() 
    {
      return akif.toJSONString() ;
    }
    
	public JSONObject getAkif() {
		return akif;
	}

	@SuppressWarnings("unchecked")
	public void setSet(String set) {
		akif.put("set", set) ;
	}
	
	@SuppressWarnings("unchecked")
	public void setId(int id)
	{
		akif.put("identifier", new Integer( id ) ) ;
	}
	
	public String audience2userRole( String audience )
	{
		if ( "Administrator".equals( audience ) )
		{
			return "manager" ;
		}
		if ( "Educator".equals( audience ) )
		{
			return "teacher" ;
		}
		if ( "Learner".equals( audience ) )
		{
			return "learner" ;
		}
		if ( "Parent/Guardian".equals( audience ) )
		{
			return "parent" ;
		}
		return "other" ;
	}
	
	@SuppressWarnings("unchecked")
	public void init()
	{
		akif = new JSONObject() ;
		akif.put( "status", "published" ) ;
		akif.put( "generateThumbnail", new Boolean( true ) ) ;
		akif.put( "creationDate", utcNow() ) ;
		akif.put( "lastUpdateDate", utcNow() ) ;
		akif.put( "languageBlocks", new JSONObject() ) ;
		akif.put( "tokenBlock", new JSONObject() ) ;
		akif.put( "expressions", new JSONArray() ) ;
		akif.put( "rights", new JSONObject() ) ;
		akif.put( "contributors", new JSONArray() ) ;
	}
	
	private String utcNow() 
	{
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat sdf = new SimpleDateFormat( "yyyy-MM-dd" );
		return sdf.format(cal.getTime());
	}
	
	private String extract( String element )
	{	
		return element.substring(element.indexOf(">") + 1 , element.indexOf("</") );
	}
	
%}

%state NSDL

%%

<YYINITIAL>
{	
	"<nsdl_dc:nsdl_dc"
	{
		yybegin( NSDL ) ;
	}
}

<NSDL>
{
	"</nsdl_dc:nsdl_dc>"
	{
		yybegin( YYINITIAL ) ;
		generate() ;
	}

	"<dc:identifier xsi:type=\"dct:URI\">".+"</dc:identifier>"
	{
		url = extract( yytext() ).trim().replaceAll("&amp;", "&" ) ;
	}
	
	"<dc:title>".+"</dc:title>"
	{
		title = extract( yytext() ).trim() ;
	}

	"<dc:description>".+"</dc:description>"
	{
		description = extract( yytext() ).trim() ;
	}
	
	"<dct:educationLevel xsi:type=\"nsdl_dc:NSDLEdLevel\">".+"</dct:educationLevel>"
	{
		String nsdlEdLevel = extract( yytext() ).trim() ;
		if ( "Vocational/Professional Development Education".equals( nsdlEdLevel ) )
		{
			contexts.add( "professional development" ) ;	
		}
		else if ( "Informal Education".equals( nsdlEdLevel ) )
		{
			contexts.add( "continuing education" ) ;	
		}
		nsdlAge.SetEducationalLevel( nsdlEdLevel ) ;
		
	}
	
	"<dc:language>".+"</dc:language>"
	{
		try 
		{
			language = Toolbox.getInstance().language2iso( extract( yytext() ).trim() ) ;
		} 
		catch (ToolboxException e) 
		{
			e.printStackTrace();
		}
	}
	
	"<dct:accessRights xsi:type=\"nsdl_dc:NSDLAccess\">".+"</dct:accessRights>"
	{
		rights = extract( yytext() ).trim() ;
	}
	
	"<dc:type xsi:type=\"nsdl_dc:NSDLType\">".+<"/dc:type>"
	{
		try
		{
			lrt.submitNSDLResourceType( extract( yytext() ).trim() ) ;
		}
		catch( ToolboxException tbe )
		{
			tbe.printStackTrace() ;
		}
	}
	
	"<dc:type>".+"</dc:type>"
	{
		try
		{
			lrt.submitNSDLResourceType( extract( yytext() ).trim() ) ;
		}
		catch( ToolboxException tbe )
		{
			tbe.printStackTrace() ;
		}
	}
	
	"<dc:format xsi:type=\"dct:IMT\">".+"</dc:format>"
	{
		format = extract( yytext() ).trim() ;
	}
	
	"<dc:subject>".+"</dc:subject>"
	{
		keywords.add( extract( yytext() ).trim() ) ;
	}
	
	"<dct:audience xsi:type=\"nsdl_dc:NSDLAudience\">".+"</dct:audience>"
	{
		endUsers.add( audience2userRole( extract( yytext() ).trim() ) ) ;
	}
	
	"<dct:created xsi:type=\"dct:W3CDTF\">".+"</dct:created>"
	{
		creationDate = extract( yytext() ).trim() ;
	}

	"<dc:creator>".+"</dc:creator>"
	{
		author = extract( yytext() ).trim() ;
	}

	"<dct:rightsHolder>".+"</dct:rightsHolder>"
	{
		licensor = extract( yytext() ).trim() ;
	}  
}

/* error fallback */
.|\n 
{
	//throw new Error("Illegal character <"+ yytext()+">") ;
}