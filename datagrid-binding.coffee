templateEngine = new ko.nativeTemplateEngine()

templateEngine.addTemplate = (templateName, templateMarkup) ->
    document.write("<script type='text/html' id='#{templateName}'>#{templateMarkup}</script>")

templateEngine.addTemplate("ko_datagrid_search", "<span style=\"display:none\" data-bind=\"visible:$root.searchable\" class=\"ko-datagrid-search\"><input data-bind=\"value:searchInput, valueUpdate:'keyup'\" placeholder='search' /></span>")

templateEngine.addTemplate("ko_datagrid_lengthMenu", "<span style=\"display:none\" data-bind=\"visible:$root.lengthMenu\" class=\"ko-datagrid-lengthMenu\"><select data-bind=\"options: [5, 10, 20, 30, 40, 50, 100], value: $root.pageLength\"></select></span>")

templateEngine.addTemplate("ko_datagrid_grid", "<form class=\"ko-datagrid-form\"><table border=\"1\" class=\"ko-datagrid\" cellspacing=\"0\">
                                                    <thead>
                                                        <tr data-bind=\"foreach: columns\">
                                                           <!-- ko if: $root.selectable && $index() == 0 -->
                                                               <td></td>
                                                           <!-- /ko -->
                                                           <th data-bind=\"click:function(){$root.sortColumn(rowText)}, style: {cursor: $root.sortable ? 'pointer' : 'auto'}, text: headerText\"></th>
                                                        </tr>
                                                    </thead>
                                                    <tbody data-bind=\"foreach: itemsOnCurrentPage\">
                                                       <tr data-bind=\"foreach: $parent.columns\">
                                                           <!-- ko if: $root.selectable && $index() == 0 -->
                                                               <td><input data-bind=\"attr: {type: $root.selectStyle, name: rowText + $index()}\"/></td>
                                                           <!-- /ko -->
                                                           <td data-bind=\"text: typeof rowText == 'function' ? rowText($parent) : $parent[rowText] \"></td>
                                                        </tr>
                                                    </tbody>
                                                    <tfoot>
                                                        <tr>
                                                            <td style=\"display:none\" data-bind=\"visible: itemsOnCurrentPage().length == 0, attr: {colspan: $root.selectable ? columns.length + 1 : columns.length}\">No results found</td>
                                                        </tr>
                                                    </tfoot>
                                                </table></form>")

templateEngine.addTemplate("ko_datagrid_pageLinks", "<span style=\"display:none\" data-bind=\"visible:$root.paging && $root.maxPageIndex() !== -1\" class=\"ko-datagrid-pageLinks\">
                                                        <!-- ko foreach: ko.utils.range(0, maxPageIndex) -->
                                                               <a href=\"#\" data-bind=\"text: $data + 1, click: function() { $root.currentPageIndex($data) }, style: {color: ($data == $root.currentPageIndex()) ? 'black' : 'blue'}, css: { 'ko-datagrid-selected-page': $data == $root.currentPageIndex() }\">
                                                            </a>
                                                        <!-- /ko -->
                                                    </span>")


ko.bindingHandlers.datagrid = {
    init: ->
        return {'controlsDescendantBindings': yes}

    update: (element, viewModelAccessor, allBindings) ->
        viewModel = viewModelAccessor()

        ko.removeNode(element.firstChild) while element.firstChild

        searchContainer = element.appendChild(document.createElement("DIV"))
        ko.renderTemplate("ko_datagrid_search", viewModel, { templateEngine: templateEngine }, searchContainer, "replaceNode")

        lengthMenuContainer = element.appendChild(document.createElement("DIV"))
        ko.renderTemplate("ko_datagrid_lengthMenu", viewModel, { templateEngine: templateEngine }, lengthMenuContainer, "replaceNode")

        gridContainer = element.appendChild(document.createElement("DIV"))
        ko.renderTemplate("ko_datagrid_grid", viewModel, { templateEngine: templateEngine }, gridContainer, "replaceNode")

        pageLinksContainer = element.appendChild(document.createElement("DIV"))
        ko.renderTemplate("ko_datagrid_pageLinks", viewModel, { templateEngine: templateEngine }, pageLinksContainer, "replaceNode")
}

ko.datagrid = {}

class ko.datagrid.DataGridViewModel
    constructor: (config) ->
        @data = ko.observableArray(ko.unwrap(config.data))
        @pageLength = ko.observable(config.options?.pageLength ? 10)

        @columns = ko.unwrap(config.columns)
        {@sortable, @searchable, @lengthMenu, @paging, @selectable, @selectStyle} = config.options
        @selectStyle ?= if @selectStyle is "radio" then "radio" else "checkbox"

        @currentPageIndex = ko.observable(0)
        @searchInput = ko.observable("")
        @searchableData = ko.computed(=>
            if not @searchInput()? or @searchInput().length is 0
                return @data()
            else
                results = []
                for item in @data()
                    searchString = ""
                    for own key of item
                        searchString += item[key]
                    results.push(item) if searchString.toLowerCase().indexOf(@searchInput().toLowerCase()) isnt -1
                return results
        )

        @updateColumnSortState = (column, state) ->
            updatedColumns = []
            for col in @columns
                if col.rowText is column
                    col.sortState = state
                updatedColumns.push(col)
            @columns = updatedColumns

        @columnSortState = (column) ->
            return col.sortState for col in @columns when col.rowText is column

        @sortColumn = (column) ->
            if @sortable? and @sortable
                if @columnSortState(column) is "asc"
                    @data(@data().sort((obj1, obj2) =>
                        @updateColumnSortState(column, "dsc")
                        if obj1[column] is obj2[column] then 0 else if obj1[column] < obj2[column] then 1 else -1
                    ))
                else
                    @data(@data().sort((obj1, obj2) =>
                        @updateColumnSortState(column, "asc")
                        if obj1[column] is obj2[column] then 0 else if obj1[column] < obj2[column] then -1 else 1
                    ))

        @itemsOnCurrentPage = ko.computed(=>
            if @paging? and @paging
                startIndex = @pageLength() * @currentPageIndex()
                ko.unwrap(@searchableData).slice(startIndex, startIndex + @pageLength())
            else
                ko.unwrap(@searchableData)
        )

        @maxPageIndex = ko.computed(=>
            if @paging? and @paging
                Math.ceil(ko.unwrap(@searchableData).length / @pageLength()) - 1
            else
                return -1
        )
