﻿//------------------------------------------------------------------------------
// <autogenerated>
//     This code was generated by a tool.
//     Runtime Version: 1.1.4322.2300
//
//     Changes to this file may cause incorrect behavior and will be lost if 
//     the code is regenerated.
// </autogenerated>
//------------------------------------------------------------------------------

namespace WaypointTool {
    using System;
    using System.Data;
    using System.Xml;
    using System.Runtime.Serialization;
    
    
    [Serializable()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Diagnostics.DebuggerStepThrough()]
    [System.ComponentModel.ToolboxItem(true)]
    public class Bots : DataSet {
        
        private BotDataTable tableBot;
        
        public Bots() {
            this.InitClass();
            System.ComponentModel.CollectionChangeEventHandler schemaChangedHandler = new System.ComponentModel.CollectionChangeEventHandler(this.SchemaChanged);
            this.Tables.CollectionChanged += schemaChangedHandler;
            this.Relations.CollectionChanged += schemaChangedHandler;
        }
        
        protected Bots(SerializationInfo info, StreamingContext context) {
            string strSchema = ((string)(info.GetValue("XmlSchema", typeof(string))));
            if ((strSchema != null)) {
                DataSet ds = new DataSet();
                ds.ReadXmlSchema(new XmlTextReader(new System.IO.StringReader(strSchema)));
                if ((ds.Tables["Bot"] != null)) {
                    this.Tables.Add(new BotDataTable(ds.Tables["Bot"]));
                }
                this.DataSetName = ds.DataSetName;
                this.Prefix = ds.Prefix;
                this.Namespace = ds.Namespace;
                this.Locale = ds.Locale;
                this.CaseSensitive = ds.CaseSensitive;
                this.EnforceConstraints = ds.EnforceConstraints;
                this.Merge(ds, false, System.Data.MissingSchemaAction.Add);
                this.InitVars();
            }
            else {
                this.InitClass();
            }
            this.GetSerializationData(info, context);
            System.ComponentModel.CollectionChangeEventHandler schemaChangedHandler = new System.ComponentModel.CollectionChangeEventHandler(this.SchemaChanged);
            this.Tables.CollectionChanged += schemaChangedHandler;
            this.Relations.CollectionChanged += schemaChangedHandler;
        }
        
        [System.ComponentModel.Browsable(false)]
        [System.ComponentModel.DesignerSerializationVisibilityAttribute(System.ComponentModel.DesignerSerializationVisibility.Content)]
        public BotDataTable Bot {
            get {
                return this.tableBot;
            }
        }
        
        public override DataSet Clone() {
            Bots cln = ((Bots)(base.Clone()));
            cln.InitVars();
            return cln;
        }
        
        protected override bool ShouldSerializeTables() {
            return false;
        }
        
        protected override bool ShouldSerializeRelations() {
            return false;
        }
        
        protected override void ReadXmlSerializable(XmlReader reader) {
            this.Reset();
            DataSet ds = new DataSet();
            ds.ReadXml(reader);
            if ((ds.Tables["Bot"] != null)) {
                this.Tables.Add(new BotDataTable(ds.Tables["Bot"]));
            }
            this.DataSetName = ds.DataSetName;
            this.Prefix = ds.Prefix;
            this.Namespace = ds.Namespace;
            this.Locale = ds.Locale;
            this.CaseSensitive = ds.CaseSensitive;
            this.EnforceConstraints = ds.EnforceConstraints;
            this.Merge(ds, false, System.Data.MissingSchemaAction.Add);
            this.InitVars();
        }
        
        protected override System.Xml.Schema.XmlSchema GetSchemaSerializable() {
            System.IO.MemoryStream stream = new System.IO.MemoryStream();
            this.WriteXmlSchema(new XmlTextWriter(stream, null));
            stream.Position = 0;
            return System.Xml.Schema.XmlSchema.Read(new XmlTextReader(stream), null);
        }
        
        internal void InitVars() {
            this.tableBot = ((BotDataTable)(this.Tables["Bot"]));
            if ((this.tableBot != null)) {
                this.tableBot.InitVars();
            }
        }
        
        private void InitClass() {
            this.DataSetName = "Bots";
            this.Prefix = "";
            this.Namespace = "http://tempuri.org/Bots.xsd";
            this.Locale = new System.Globalization.CultureInfo("en-US");
            this.CaseSensitive = false;
            this.EnforceConstraints = true;
            this.tableBot = new BotDataTable();
            this.Tables.Add(this.tableBot);
        }
        
        private bool ShouldSerializeBot() {
            return false;
        }
        
        private void SchemaChanged(object sender, System.ComponentModel.CollectionChangeEventArgs e) {
            if ((e.Action == System.ComponentModel.CollectionChangeAction.Remove)) {
                this.InitVars();
            }
        }
        
        public delegate void BotRowChangeEventHandler(object sender, BotRowChangeEvent e);
        
        [System.Diagnostics.DebuggerStepThrough()]
        public class BotDataTable : DataTable, System.Collections.IEnumerable {
            
            private DataColumn columnName;
            
            private DataColumn columnFunName;
            
            private DataColumn columnClass;
            
            private DataColumn columnWeapon;
            
            private DataColumn columnTeam;
            
            internal BotDataTable() : 
                    base("Bot") {
                this.InitClass();
            }
            
            internal BotDataTable(DataTable table) : 
                    base(table.TableName) {
                if ((table.CaseSensitive != table.DataSet.CaseSensitive)) {
                    this.CaseSensitive = table.CaseSensitive;
                }
                if ((table.Locale.ToString() != table.DataSet.Locale.ToString())) {
                    this.Locale = table.Locale;
                }
                if ((table.Namespace != table.DataSet.Namespace)) {
                    this.Namespace = table.Namespace;
                }
                this.Prefix = table.Prefix;
                this.MinimumCapacity = table.MinimumCapacity;
                this.DisplayExpression = table.DisplayExpression;
            }
            
            [System.ComponentModel.Browsable(false)]
            public int Count {
                get {
                    return this.Rows.Count;
                }
            }
            
            internal DataColumn NameColumn {
                get {
                    return this.columnName;
                }
            }
            
            internal DataColumn FunNameColumn {
                get {
                    return this.columnFunName;
                }
            }
            
            internal DataColumn ClassColumn {
                get {
                    return this.columnClass;
                }
            }
            
            internal DataColumn WeaponColumn {
                get {
                    return this.columnWeapon;
                }
            }
            
            internal DataColumn TeamColumn {
                get {
                    return this.columnTeam;
                }
            }
            
            public BotRow this[int index] {
                get {
                    return ((BotRow)(this.Rows[index]));
                }
            }
            
            public event BotRowChangeEventHandler BotRowChanged;
            
            public event BotRowChangeEventHandler BotRowChanging;
            
            public event BotRowChangeEventHandler BotRowDeleted;
            
            public event BotRowChangeEventHandler BotRowDeleting;
            
            public void AddBotRow(BotRow row) {
                this.Rows.Add(row);
            }
            
            public BotRow AddBotRow(string Name, string FunName, string Class, string Weapon, string Team) {
                BotRow rowBotRow = ((BotRow)(this.NewRow()));
                rowBotRow.ItemArray = new object[] {
                        Name,
                        FunName,
                        Class,
                        Weapon,
                        Team};
                this.Rows.Add(rowBotRow);
                return rowBotRow;
            }
            
            public System.Collections.IEnumerator GetEnumerator() {
                return this.Rows.GetEnumerator();
            }
            
            public override DataTable Clone() {
                BotDataTable cln = ((BotDataTable)(base.Clone()));
                cln.InitVars();
                return cln;
            }
            
            protected override DataTable CreateInstance() {
                return new BotDataTable();
            }
            
            internal void InitVars() {
                this.columnName = this.Columns["Name"];
                this.columnFunName = this.Columns["FunName"];
                this.columnClass = this.Columns["Class"];
                this.columnWeapon = this.Columns["Weapon"];
                this.columnTeam = this.Columns["Team"];
            }
            
            private void InitClass() {
                this.columnName = new DataColumn("Name", typeof(string), null, System.Data.MappingType.Element);
                this.Columns.Add(this.columnName);
                this.columnFunName = new DataColumn("FunName", typeof(string), null, System.Data.MappingType.Element);
                this.Columns.Add(this.columnFunName);
                this.columnClass = new DataColumn("Class", typeof(string), null, System.Data.MappingType.Element);
                this.Columns.Add(this.columnClass);
                this.columnWeapon = new DataColumn("Weapon", typeof(string), null, System.Data.MappingType.Element);
                this.Columns.Add(this.columnWeapon);
                this.columnTeam = new DataColumn("Team", typeof(string), null, System.Data.MappingType.Element);
                this.Columns.Add(this.columnTeam);
            }
            
            public BotRow NewBotRow() {
                return ((BotRow)(this.NewRow()));
            }
            
            protected override DataRow NewRowFromBuilder(DataRowBuilder builder) {
                return new BotRow(builder);
            }
            
            protected override System.Type GetRowType() {
                return typeof(BotRow);
            }
            
            protected override void OnRowChanged(DataRowChangeEventArgs e) {
                base.OnRowChanged(e);
                if ((this.BotRowChanged != null)) {
                    this.BotRowChanged(this, new BotRowChangeEvent(((BotRow)(e.Row)), e.Action));
                }
            }
            
            protected override void OnRowChanging(DataRowChangeEventArgs e) {
                base.OnRowChanging(e);
                if ((this.BotRowChanging != null)) {
                    this.BotRowChanging(this, new BotRowChangeEvent(((BotRow)(e.Row)), e.Action));
                }
            }
            
            protected override void OnRowDeleted(DataRowChangeEventArgs e) {
                base.OnRowDeleted(e);
                if ((this.BotRowDeleted != null)) {
                    this.BotRowDeleted(this, new BotRowChangeEvent(((BotRow)(e.Row)), e.Action));
                }
            }
            
            protected override void OnRowDeleting(DataRowChangeEventArgs e) {
                base.OnRowDeleting(e);
                if ((this.BotRowDeleting != null)) {
                    this.BotRowDeleting(this, new BotRowChangeEvent(((BotRow)(e.Row)), e.Action));
                }
            }
            
            public void RemoveBotRow(BotRow row) {
                this.Rows.Remove(row);
            }
        }
        
        [System.Diagnostics.DebuggerStepThrough()]
        public class BotRow : DataRow {
            
            private BotDataTable tableBot;
            
            internal BotRow(DataRowBuilder rb) : 
                    base(rb) {
                this.tableBot = ((BotDataTable)(this.Table));
            }
            
            public string Name {
                get {
                    try {
                        return ((string)(this[this.tableBot.NameColumn]));
                    }
                    catch (InvalidCastException e) {
                        throw new StrongTypingException("Cannot get value because it is DBNull.", e);
                    }
                }
                set {
                    this[this.tableBot.NameColumn] = value;
                }
            }
            
            public string FunName {
                get {
                    try {
                        return ((string)(this[this.tableBot.FunNameColumn]));
                    }
                    catch (InvalidCastException e) {
                        throw new StrongTypingException("Cannot get value because it is DBNull.", e);
                    }
                }
                set {
                    this[this.tableBot.FunNameColumn] = value;
                }
            }
            
            public string Class {
                get {
                    try {
                        return ((string)(this[this.tableBot.ClassColumn]));
                    }
                    catch (InvalidCastException e) {
                        throw new StrongTypingException("Cannot get value because it is DBNull.", e);
                    }
                }
                set {
                    this[this.tableBot.ClassColumn] = value;
                }
            }
            
            public string Weapon {
                get {
                    try {
                        return ((string)(this[this.tableBot.WeaponColumn]));
                    }
                    catch (InvalidCastException e) {
                        throw new StrongTypingException("Cannot get value because it is DBNull.", e);
                    }
                }
                set {
                    this[this.tableBot.WeaponColumn] = value;
                }
            }
            
            public string Team {
                get {
                    try {
                        return ((string)(this[this.tableBot.TeamColumn]));
                    }
                    catch (InvalidCastException e) {
                        throw new StrongTypingException("Cannot get value because it is DBNull.", e);
                    }
                }
                set {
                    this[this.tableBot.TeamColumn] = value;
                }
            }
            
            public bool IsNameNull() {
                return this.IsNull(this.tableBot.NameColumn);
            }
            
            public void SetNameNull() {
                this[this.tableBot.NameColumn] = System.Convert.DBNull;
            }
            
            public bool IsFunNameNull() {
                return this.IsNull(this.tableBot.FunNameColumn);
            }
            
            public void SetFunNameNull() {
                this[this.tableBot.FunNameColumn] = System.Convert.DBNull;
            }
            
            public bool IsClassNull() {
                return this.IsNull(this.tableBot.ClassColumn);
            }
            
            public void SetClassNull() {
                this[this.tableBot.ClassColumn] = System.Convert.DBNull;
            }
            
            public bool IsWeaponNull() {
                return this.IsNull(this.tableBot.WeaponColumn);
            }
            
            public void SetWeaponNull() {
                this[this.tableBot.WeaponColumn] = System.Convert.DBNull;
            }
            
            public bool IsTeamNull() {
                return this.IsNull(this.tableBot.TeamColumn);
            }
            
            public void SetTeamNull() {
                this[this.tableBot.TeamColumn] = System.Convert.DBNull;
            }
        }
        
        [System.Diagnostics.DebuggerStepThrough()]
        public class BotRowChangeEvent : EventArgs {
            
            private BotRow eventRow;
            
            private DataRowAction eventAction;
            
            public BotRowChangeEvent(BotRow row, DataRowAction action) {
                this.eventRow = row;
                this.eventAction = action;
            }
            
            public BotRow Row {
                get {
                    return this.eventRow;
                }
            }
            
            public DataRowAction Action {
                get {
                    return this.eventAction;
                }
            }
        }
    }
}
