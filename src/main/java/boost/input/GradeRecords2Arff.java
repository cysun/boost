package boost.input;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Properties;
import java.util.Set;

import boost.model.ArffInstance;
import boost.model.GradeRecord;

public class GradeRecords2Arff {

    Properties props;

    public GradeRecords2Arff() throws IOException
    {
        props = new Properties();
        try (InputStream stream = GradeRecords2Arff.class.getClassLoader()
            .getResourceAsStream( "config.properties" ))
        {
            props.load( stream );
        }
    }

    public static void main( String args[] ) throws SQLException, IOException
    {
        GradeRecords2Arff g2a = new GradeRecords2Arff();
        List<GradeRecord> records = g2a.loadGradeRecords();
        List<ArffInstance> instances = g2a.createArffInstances( records );
        g2a.writeArffFile( instances );
    }

    public List<GradeRecord> loadGradeRecords() throws SQLException
    {
        List<GradeRecord> records = new ArrayList<GradeRecord>();
        String query = "select * from records where "
            + props.getProperty( "year.start" ) + " <= year and year <=  "
            + props.getProperty( "year.end" ) + " order by student, term";

        try (
            Connection c = DriverManager.getConnection(
                props.getProperty( "db.url" ),
                props.getProperty( "db.username" ),
                props.getProperty( "db.password" ) );
            Statement stmt = c.createStatement();
            ResultSet rs = stmt.executeQuery( query );)
        {
            while( rs.next() )
            {
                GradeRecord record = new GradeRecord();
                record.setStudent( rs.getLong( "student" ) );
                record.setCourse( rs.getString( "course" ) );
                record.setTerm( rs.getInt( "term" ) );
                record.setYear( rs.getInt( "year" ) );
                record.setSymbol( rs.getString( "grade_symbol" ) );
                record.setValue( rs.getDouble( "grade_value" ) );
                records.add( record );
            }
        }

        System.out.println( records.size() + " records loaded." );
        return records;
    }

    public List<ArffInstance> createArffInstances( List<GradeRecord> records )
    {
        ArffInstance.attributes = props.getProperty( "attributes" )
            .split( "," );
        Set<String> classes = new HashSet<String>();
        for( String s : props.getProperty( "classes" ).split( "," ) )
            classes.add( s );

        List<ArffInstance> instances = new ArrayList<ArffInstance>();
        ArffInstance instance = null;
        for( GradeRecord record : records )
        {
            if( instance == null
                || !instance.getId().equals( record.getStudent() ) )
            {
                instance = new ArffInstance( record.getStudent() );
                instances.add( instance );
            }

            if( classes.contains( record.getCourse() ) )
                instance.setLabel( true );
            else
                instance.setValue( record.getCourse(), record.getValue() );
        }

        System.out.println( instances.size() + " instances created." );
        return instances;
    }

    public void writeArffFile( List<ArffInstance> instances ) throws IOException
    {
        String startYear = props.getProperty( "year.start" );
        String endYear = props.getProperty( "year.end" );
        String attributes[] = props.getProperty( "attributes" ).split( "," );

        File file = new File( props.getProperty( "output.dir" ),
            "grades-" + startYear + "-" + endYear + ".arff" );
        FileWriter out = new FileWriter( file );
        out.write( "% Grades from " + startYear + " to " + endYear + "\n" );
        out.write( "@relation grades\n\n" );
        for( String attribute : attributes )
            out.write( "@attribute " + attribute + " numeric\n" );
        out.write( "@attribute graduated {true, false}\n\n" );
        out.write( "@data\n" );
        for( ArffInstance instance : instances )
            out.write( instance.toString() + "\n" );
        out.close();

        System.out.println( "Finished writing file " + file.getName() );
    }

}
