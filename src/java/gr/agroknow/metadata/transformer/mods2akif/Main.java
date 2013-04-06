package gr.agroknow.metadata.transformer.mods2akif;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import net.zettadata.generator.tools.NSDLAgeRange;

import org.apache.commons.io.FileUtils;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;


public class Main 
{
//	public static final String SET = "NSDLBEYOND" ;
	
//	public static final String INPUT_FOLDER = "/Users/dmssrt/tmp/transformer/NSDL/" + SET ;
//	public static final String OUTPUT_FOLDER = "/Users/dmssrt/tmp/transformer/AKIF/" + SET  ;
	
	public static void main(String[] args) throws IOException
	{	
		if ( args.length != 4 )
		{
			System.err.println( "Usage : java -jar mods2akif.jar <INPUT_FOLDER> <OUTPUT_FOLDER> <BAD_FOLDER> <SET_NAME>" ) ;
			System.exit( -1 ) ;
		}
		String inputFolder = args[0] ;
		String outputFolder = args[1] ;
		String badFolder = args[2] ;
		String set = args[3] ;
		
		MODS2AKIF transformer = null ;
		int identifier = 0 ;
		File inputDirectory = new File( inputFolder ) ;
		FileReader fr = null ;
		int wrong = 0 ;
		for (String mods: inputDirectory.list() )
		{
			try
			{
				identifier = Integer.parseInt( nsdl.substring(0, nsdl.length()-4 ) ) ;
				fr = new FileReader( inputFolder + File.separator + mods ) ;
				transformer = new MODS2AKIF( fr ) ;
				transformer.init() ;
				transformer.setId( identifier ) ;
				transformer.setSet( set ) ;
				transformer.yylex() ;
				FileUtils.writeStringToFile( new File( outputFolder + "/" + identifier + ".json" ) , transformer.toString() ) ;
			}
			catch( Exception e )
			{
				wrong++ ;
				FileUtils.copyFile( new File(inputFolder + File.separator + nsdl) , new File( badFolder + File.separator + nsdl ) )  ;
				System.out.println( "Wrong file : " + identifier ) ;
				e.printStackTrace() ;
				System.exit( identifier ) ;
			}
			finally
			{
				try 
				{
					fr.close() ;
				} 
				catch (IOException e) 
				{
					e.printStackTrace();
				}
			}
		}
		System.out.println( "#wrong : " + wrong ) ;
	}

}
