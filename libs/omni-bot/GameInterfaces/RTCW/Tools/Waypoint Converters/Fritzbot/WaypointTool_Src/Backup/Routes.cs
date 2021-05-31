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
    public class Routes : DataSet {
        
        private RouteDataTable tableRoute;
        
        public Routes() {
            this.InitClass();
            System.ComponentModel.CollectionChangeEventHandler schemaChangedHandler = new System.ComponentModel.CollectionChangeEventHandler(this.SchemaChanged);
            this.Tables.CollectionChanged += schemaChangedHandler;
            this.Relations.CollectionChanged += schemaChangedHandler;
        }
        
        protected Routes(SerializationInfo info, StreamingContext context) {
            string strSchema = ((string)(info.GetValue("XmlSchema", typeof(string))));
            if ((strSchema != null)) {
                DataSet ds = new DataSet();
                ds.ReadXmlSchema(new XmlTextReader(new System.IO.StringReader(strSchema)));
                if ((ds.Tables["Route"] != null)) {
                    this.Tables.Add(new RouteDataTable(ds.Tables["Route"]));
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
        public RouteDataTable Route {
            get {
                return this.tableRoute;
            }
        }
        
        public override DataSet Clone() {
            Routes cln = ((Routes)(base.Clone()));
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
            if ((ds.Tables["Route"] != null)) {
                this.Tables.Add(new RouteDataTable(ds.Tables["Route"]));
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
            this.tableRoute = ((RouteDataTable)(this.Tables["Route"]));
            if ((this.tableRoute != null)) {
                this.tableRoute.InitVars();
            }
        }
        
        private void InitClass() {
            this.DataSetName = "Routes";
            this.Prefix = "";
            this.Namespace = "http://tempuri.org/Routes.xsd";
            this.Locale = new System.Globalization.CultureInfo("en-US");
            this.CaseSensitive = false;
            this.EnforceConstraints = true;
            this.tableRoute = new RouteDataTable();
            this.Tables.Add(this.tableRoute);
        }
        
        private bool ShouldSerializeRoute() {
            return false;
        }
        
        private void SchemaChanged(object sender, System.ComponentModel.CollectionChangeEventArgs e) {
            if ((e.Action == System.ComponentModel.CollectionChangeAction.Remove)) {
                this.InitVars();
            }
        }
        
        public delegate void RouteRowChangeEventHandler(object sender, RouteRowChangeEvent e);
        
        [System.Diagnostics.DebuggerStepThrough()]
        public class RouteDataTable : DataTable, System.Collections.IEnumerable {
            
            private DataColumn columnID;
            
            private DataColumn columnTeam;
            
            private DataColumn columnRadius;
            
            private DataColumn columnActions;
            
            private DataColumn columnPathActions;
            
            internal RouteDataTable() : 
                    base("Route") {
                this.InitClass();
            }
            
            internal RouteDataTable(DataTable table) : 
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
            
            internal DataColumn IDColumn {
                get {
                    return this.columnID;
                }
            }
            
            internal DataColumn TeamColumn {
                get {
                    return this.columnTeam;
                }
            }
            
            internal DataColumn RadiusColumn {
                get {
                    return this.columnRadius;
                }
            }
            
            internal DataColumn ActionsColumn {
                get {
                    return this.columnActions;
                }
            }
            
            internal DataColumn PathActionsColumn {
                get {
                    return this.columnPathActions;
                }
            }
            
            public RouteRow this[int index] {
                get {
                    return ((RouteRow)(this.Rows[index]));
                }
            }
            
            public event RouteRowChangeEventHandler RouteRowChanged;
            
            public event RouteRowChangeEventHandler RouteRowChanging;
            
            public event RouteRowChangeEventHandler RouteRowDeleted;
            
            public event RouteRowChangeEventHandler RouteRowDeleting;
            
            public void AddRouteRow(RouteRow row) {
                this.Rows.Add(row);
            }
            
            public RouteRow AddRouteRow(string ID, string Team, string Radius, string Actions, string PathActions) {
                RouteRow rowRouteRow = ((RouteRow)(this.NewRow()));
                rowRouteRow.ItemArray = new object[] {
                        ID,
                        Team,
                        Radius,
                        Actions,
                        PathActions};
                this.Rows.Add(rowRouteRow);
                return rowRouteRow;
            }
            
            public System.Collections.IEnumerator GetEnumerator() {
                return this.Rows.GetEnumerator();
            }
            
            public override DataTable Clone() {
                RouteDataTable cln = ((RouteDataTable)(base.Clone()));
                cln.InitVars();
                return cln;
            }
            
            protected override DataTable CreateInstance() {
                return new RouteDataTable();
            }
            
            internal void InitVars() {
                this.columnID = this.Columns["ID"];
                this.columnTeam = this.Columns["Team"];
                this.columnRadius = this.Columns["Radius"];
                this.columnActions = this.Columns["Actions"];
                this.columnPathActions = this.Columns["PathActions"];
            }
            
            private void InitClass() {
                this.columnID = new DataColumn("ID", typeof(string), null, System.Data.MappingType.Element);
                this.Columns.Add(this.columnID);
                this.columnTeam = new DataColumn("Team", typeof(string), null, System.Data.MappingType.Element);
                this.Columns.Add(this.columnTeam);
                this.columnRadius = new DataColumn("Radius", typeof(string), null, System.Data.MappingType.Element);
                this.Columns.Add(this.columnRadius);
                this.columnActions = new DataColumn("Actions", typeof(string), null, System.Data.MappingType.Element);
                this.Columns.Add(this.columnActions);
                this.columnPathActions = new DataColumn("PathActions", typeof(string), null, System.Data.MappingType.Element);
                this.Columns.Add(this.columnPathActions);
            }
            
            public RouteRow NewRouteRow() {
                return ((RouteRow)(this.NewRow()));
            }
            
            protected override DataRow NewRowFromBuilder(DataRowBuilder builder) {
                return new RouteRow(builder);
            }
            
            protected override System.Type GetRowType() {
                return typeof(RouteRow);
            }
            
            protected override void OnRowChanged(DataRowChangeEventArgs e) {
                base.OnRowChanged(e);
                if ((this.RouteRowChanged != null)) {
                    this.RouteRowChanged(this, new RouteRowChangeEvent(((RouteRow)(e.Row)), e.Action));
                }
            }
            
            protected override void OnRowChanging(DataRowChangeEventArgs e) {
                base.OnRowChanging(e);
                if ((this.RouteRowChanging != null)) {
                    this.RouteRowChanging(this, new RouteRowChangeEvent(((RouteRow)(e.Row)), e.Action));
                }
            }
            
            protected override void OnRowDeleted(DataRowChangeEventArgs e) {
                base.OnRowDeleted(e);
                if ((this.RouteRowDeleted != null)) {
                    this.RouteRowDeleted(this, new RouteRowChangeEvent(((RouteRow)(e.Row)), e.Action));
                }
            }
            
            protected override void OnRowDeleting(DataRowChangeEventArgs e) {
                base.OnRowDeleting(e);
                if ((this.RouteRowDeleting != null)) {
                    this.RouteRowDeleting(this, new RouteRowChangeEvent(((RouteRow)(e.Row)), e.Action));
                }
            }
            
            public void RemoveRouteRow(RouteRow row) {
                this.Rows.Remove(row);
            }
        }
        
        [System.Diagnostics.DebuggerStepThrough()]
        public class RouteRow : DataRow {
            
            private RouteDataTable tableRoute;
            
            internal RouteRow(DataRowBuilder rb) : 
                    base(rb) {
                this.tableRoute = ((RouteDataTable)(this.Table));
            }
            
            public string ID {
                get {
                    try {
                        return ((string)(this[this.tableRoute.IDColumn]));
                    }
                    catch (InvalidCastException e) {
                        throw new StrongTypingException("Cannot get value because it is DBNull.", e);
                    }
                }
                set {
                    this[this.tableRoute.IDColumn] = value;
                }
            }
            
            public string Team {
                get {
                    try {
                        return ((string)(this[this.tableRoute.TeamColumn]));
                    }
                    catch (InvalidCastException e) {
                        throw new StrongTypingException("Cannot get value because it is DBNull.", e);
                    }
                }
                set {
                    this[this.tableRoute.TeamColumn] = value;
                }
            }
            
            public string Radius {
                get {
                    try {
                        return ((string)(this[this.tableRoute.RadiusColumn]));
                    }
                    catch (InvalidCastException e) {
                        throw new StrongTypingException("Cannot get value because it is DBNull.", e);
                    }
                }
                set {
                    this[this.tableRoute.RadiusColumn] = value;
                }
            }
            
            public string Actions {
                get {
                    try {
                        return ((string)(this[this.tableRoute.ActionsColumn]));
                    }
                    catch (InvalidCastException e) {
                        throw new StrongTypingException("Cannot get value because it is DBNull.", e);
                    }
                }
                set {
                    this[this.tableRoute.ActionsColumn] = value;
                }
            }
            
            public string PathActions {
                get {
                    try {
                        return ((string)(this[this.tableRoute.PathActionsColumn]));
                    }
                    catch (InvalidCastException e) {
                        throw new StrongTypingException("Cannot get value because it is DBNull.", e);
                    }
                }
                set {
                    this[this.tableRoute.PathActionsColumn] = value;
                }
            }
            
            public bool IsIDNull() {
                return this.IsNull(this.tableRoute.IDColumn);
            }
            
            public void SetIDNull() {
                this[this.tableRoute.IDColumn] = System.Convert.DBNull;
            }
            
            public bool IsTeamNull() {
                return this.IsNull(this.tableRoute.TeamColumn);
            }
            
            public void SetTeamNull() {
                this[this.tableRoute.TeamColumn] = System.Convert.DBNull;
            }
            
            public bool IsRadiusNull() {
                return this.IsNull(this.tableRoute.RadiusColumn);
            }
            
            public void SetRadiusNull() {
                this[this.tableRoute.RadiusColumn] = System.Convert.DBNull;
            }
            
            public bool IsActionsNull() {
                return this.IsNull(this.tableRoute.ActionsColumn);
            }
            
            public void SetActionsNull() {
                this[this.tableRoute.ActionsColumn] = System.Convert.DBNull;
            }
            
            public bool IsPathActionsNull() {
                return this.IsNull(this.tableRoute.PathActionsColumn);
            }
            
            public void SetPathActionsNull() {
                this[this.tableRoute.PathActionsColumn] = System.Convert.DBNull;
            }
        }
        
        [System.Diagnostics.DebuggerStepThrough()]
        public class RouteRowChangeEvent : EventArgs {
            
            private RouteRow eventRow;
            
            private DataRowAction eventAction;
            
            public RouteRowChangeEvent(RouteRow row, DataRowAction action) {
                this.eventRow = row;
                this.eventAction = action;
            }
            
            public RouteRow Row {
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
