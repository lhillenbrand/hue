/**
 * Autogenerated by Thrift
 *
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 */
package com.cloudera.beeswax.api;

import org.apache.commons.lang.builder.HashCodeBuilder;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.HashSet;
import java.util.Collections;
import org.apache.log4j.Logger;

import org.apache.thrift.*;
import org.apache.thrift.meta_data.*;
import org.apache.thrift.protocol.*;

public class QueryNotFoundException extends Exception implements TBase, java.io.Serializable, Cloneable {
  private static final TStruct STRUCT_DESC = new TStruct("QueryNotFoundException");

  public static final Map<Integer, FieldMetaData> metaDataMap = Collections.unmodifiableMap(new HashMap<Integer, FieldMetaData>() {{
  }});

  static {
    FieldMetaData.addStructMetaDataMap(QueryNotFoundException.class, metaDataMap);
  }

  public QueryNotFoundException() {
  }

  /**
   * Performs a deep copy on <i>other</i>.
   */
  public QueryNotFoundException(QueryNotFoundException other) {
  }

  @Override
  public QueryNotFoundException clone() {
    return new QueryNotFoundException(this);
  }

  public void setFieldValue(int fieldID, Object value) {
    switch (fieldID) {
    default:
      throw new IllegalArgumentException("Field " + fieldID + " doesn't exist!");
    }
  }

  public Object getFieldValue(int fieldID) {
    switch (fieldID) {
    default:
      throw new IllegalArgumentException("Field " + fieldID + " doesn't exist!");
    }
  }

  // Returns true if field corresponding to fieldID is set (has been asigned a value) and false otherwise
  public boolean isSet(int fieldID) {
    switch (fieldID) {
    default:
      throw new IllegalArgumentException("Field " + fieldID + " doesn't exist!");
    }
  }

  @Override
  public boolean equals(Object that) {
    if (that == null)
      return false;
    if (that instanceof QueryNotFoundException)
      return this.equals((QueryNotFoundException)that);
    return false;
  }

  public boolean equals(QueryNotFoundException that) {
    if (that == null)
      return false;

    return true;
  }

  @Override
  public int hashCode() {
    HashCodeBuilder builder = new HashCodeBuilder();

    return builder.toHashCode();
  }

  public void read(TProtocol iprot) throws TException {
    TField field;
    iprot.readStructBegin();
    while (true)
    {
      field = iprot.readFieldBegin();
      if (field.type == TType.STOP) { 
        break;
      }
      switch (field.id)
      {
        default:
          TProtocolUtil.skip(iprot, field.type);
          break;
      }
      iprot.readFieldEnd();
    }
    iprot.readStructEnd();


    // check for required fields of primitive type, which can't be checked in the validate method
    validate();
  }

  public void write(TProtocol oprot) throws TException {
    validate();

    oprot.writeStructBegin(STRUCT_DESC);
    oprot.writeFieldStop();
    oprot.writeStructEnd();
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder("QueryNotFoundException(");
    boolean first = true;

    sb.append(")");
    return sb.toString();
  }

  public void validate() throws TException {
    // check for required fields
    // check that fields of type enum have valid values
  }

}
