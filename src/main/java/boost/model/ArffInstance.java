package boost.model;

public class ArffInstance {

    public static String[] attributes;

    Long id;

    String[] values;

    Boolean label;

    public ArffInstance( Long id )
    {
        this.id = id;
        values = new String[attributes.length];
        label = false;
    }

    public void setValue( String attribute, Object value )
    {
        if( value == null ) return;

        int index = -1;
        for( int i = 0; i < attributes.length; ++i )
            if( attributes[i].equals( attribute ) )
            {
                index = i;
                break;
            }

        if( index >= 0 ) values[index] = value.toString();
    }

    @Override
    public String toString()
    {
        for( int i = 0; i < values.length; ++i )
            if( values[i] == null ) values[i] = "?";

        StringBuilder sb = new StringBuilder();
        for( int i = 0; i < values.length; ++i )
            sb.append( values[i] ).append( ", " );
        sb.append( label );

        return sb.toString();
    }

    public Long getId()
    {
        return id;
    }

    public void setId( Long id )
    {
        this.id = id;
    }

    public String[] getValues()
    {
        return values;
    }

    public void setValues( String[] values )
    {
        this.values = values;
    }

    public Boolean getLabel()
    {
        return label;
    }

    public void setLabel( Boolean label )
    {
        this.label = label;
    }

}
