@genType
type config = {
    completedToTop: bool,
}

type rec element = {
    line: string,
    children: list<element>,
}

let indentLevel = (line) => {
    open Js.String2

    let rec indentLevelRec = (curLevel, line) =>
        // TODO(Apaar): Allow adjusting tab width
        if line->startsWith("    ") {
            indentLevelRec(curLevel + 1, line->substringToEnd(~from=4))
        } else if line->startsWith("\t") {
            indentLevelRec(curLevel + 1, line->substringToEnd(~from=1))
        } else {
            curLevel
        }

    indentLevelRec(0, line)
}

let parseElements = (lines) => {
    let rec parseChildrenRec = (accElements, parentIndentLevel, lines) =>
        switch lines {
        | list{} => (accElements, lines)
        | list{line, ...restLines} =>
            let lineIndentLevel = indentLevel(line)    

            if lineIndentLevel <= parentIndentLevel {
                (accElements, lines)
            } else {
                let (children, linesAfterChildren) = parseChildrenRec(list{}, lineIndentLevel, restLines)

                let newAcc = list{
                    { line, children: children->Js.List.rev },
                    ...accElements
                }

                parseChildrenRec(newAcc, parentIndentLevel, linesAfterChildren)
            }
        }
    
    let (elements, _) = parseChildrenRec(list{}, -1, lines)

    elements->Js.List.rev
}

let taskRe = %re("/\s*[-\*]\s+\[(.?)\]/")

// If this line is a task, returns Some(whether or not the task is completed) otherwise returns null
let parseTaskIsCompleted = (line) => {
    open Js.Re
    open Js.Nullable
    open Belt.Option

    let resOpt = taskRe->exec_(line)

    resOpt->flatMap(
        (res) => {
            (res->captures)[1]->toOption
        }
    )->map((s) => s !== " ")
}

let compareElements = (a, b, cfg) => {
    open Js.String2

    let aCompletedTask = parseTaskIsCompleted(a.line)
    let bCompletedTask = parseTaskIsCompleted(b.line)

    switch (aCompletedTask, bCompletedTask, cfg.completedToTop) {
    | (None, None, _) => 0
    // Retain the order of empty lines
    | (Some(_), None, _) => b.line->trim === "" ? 0 : 1
    | (None, Some(_), _) => a.line->trim === "" ? 0 : -1
    | (Some(false), Some(false), _) => 0
    | (Some(true), Some(true), _) => 0
    | (Some(true), Some(false), true) => -1
    | (Some(false), Some(true), true) => 1
    | (Some(true), Some(false), false) => 1
    | (Some(false), Some(true), false) => -1
    }
}

let rec sortElements = (elements, cfg) => {
    open Belt.List

    let elemsWithSortedChildren = elements->map(elem => {
        line: elem.line,
        children: sortElements(elem.children, cfg)
    })

    let elementsArr = elemsWithSortedChildren->toArray
    elementsArr->Belt.SortArray.stableSortInPlaceBy((a, b) => compareElements(a, b, cfg))
    elementsArr->fromArray
}

let elementsToLines = (elements) => {
    let rec elementsToLinesRec = (accLines, elements) =>
        switch elements {
        | list{} => accLines
        | list{element, ...restElements} =>
            let accLinesWithChildren = elementsToLinesRec(list{element.line, ...accLines}, element.children)

            elementsToLinesRec(accLinesWithChildren, restElements)
        }

    let lines = elementsToLinesRec(list{}, elements)
    lines->Js.List.rev
}

@genType
let sortLines = (lines, cfg) => {
    let linesList = lines->Belt.List.fromArray
    let elements = parseElements(linesList)

    let sortedElements = sortElements(elements, cfg)
 
    elementsToLines(sortedElements)->Belt.List.toArray
}
