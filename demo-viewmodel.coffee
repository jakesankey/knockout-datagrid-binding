class ViewModel
    tableConfig: new ko.datagrid.DataGridViewModel(
        data: [
            {first: "John", last: "Smith", car: "Jetta", city: "Urbandale"}
            {first: "Jane", last: "Smith", car: "Vue", city: "Urbandale"}
            {first: "Tyler", last: "Johns", car: "Prius", city: "St. Louis"}
            {first: "Brian", last: "Peters", car: "F350", city: "Norwalk"}
            {first: "Drew", last: "Cruise", car: "Camaro", city: "San Diego"}
            {first: "Bill", last: "Jones", car: "Malibu", city: "Jacksonville"}
            {first: "Vicky", last: "Hines", car: "Escape", city: "Arlington"}
            {first: "Jenna", last: "Johnson", car: "Traverse", city: "Dallas"}
            {first: "Josh", last: "Anderson", car: "Vue", city: "Aplington"}
            {first: "Diana", last: "Anderson", car: "Bus", city: "Aplington"}
            {first: "Scott", last: "Dean", car: "F150", city: "Garner"}
            {first: "Mike", last: "Jackson", car: "F150", city: "Des Moines"}
        ]

        columns: [
            {headerText: "First", rowText: "first"}
            {headerText: "Last", rowText: "last"}
            {headerText: "Car", rowText: "car"}
            {headerText: "City", rowText: "city"}
        ]

        options: {
            pageLength: 5
            paging: yes
            lengthMenu: yes
            sortable: yes
            searchable: yes
            selectable: yes
            selectStyle: "radio"
        }
    )


$ -> ko.applyBindings(new ViewModel())
