package boost.model;

public class GradeRecord {

    Long student;

    String course;

    Integer term;

    Integer year;

    String symbol;

    Double value;

    public Boolean isPassed()
    {
        if( symbol == null || symbol.equals( "W" ) ) return null;

        return symbol.equals( "CR" ) || value != null && value >= 2 ? true
            : false;
    }

    @Override
    public String toString()
    {
        return "" + student + "|" + course + "|" + term + "|" + year + "|"
            + symbol + "|" + value;
    }

    public Long getStudent()
    {
        return student;
    }

    public void setStudent( Long student )
    {
        this.student = student;
    }

    public String getCourse()
    {
        return course;
    }

    public void setCourse( String course )
    {
        this.course = course;
    }

    public Integer getTerm()
    {
        return term;
    }

    public void setTerm( Integer term )
    {
        this.term = term;
    }

    public Integer getYear()
    {
        return year;
    }

    public void setYear( Integer year )
    {
        this.year = year;
    }

    public String getSymbol()
    {
        return symbol;
    }

    public void setSymbol( String symbol )
    {
        this.symbol = symbol;
    }

    public Double getValue()
    {
        return value;
    }

    public void setValue( Double value )
    {
        this.value = value;
    }

}
