<!doctype html>
<html>
<head>
<meta charset="UTF-8">
<title>stuct to xml test</title>
</head>

<body>

<cfset xmlObj = new AnythingToXML(0,0)>
<cfsavecontent variable="json_text">
{
  "sitemap": {
    "module": [

      {
        "title": "Module One",
        "visible": "true",
        "indexpage": "true",
        "lesson": [
          {
            "title": "Introduction to Journalism",
            "num": "01.00",
            "time": "45",
            "points": "1",
            "page": [
              {
                "href": "../../module01/lesson00/01_00_01.htm",
                "title": "01.00 Page 01"
              },
              {
                "href": "../../module01/lesson00/01_00_02.htm",
                "title": "01.00 Page 02"
              }
            ]
          },
          {
            "title": "The First Amendment",
            "num": "01.01",
            "time": "45",
            "points": "25",
            "page": [
              {
                "href": "../../module01/lesson01/01_01_01.htm",
                "title": "01.01 Page 01"
              },
              {
                "href": "../../module01/lesson01/01_01_02.htm",
                "title": "01.01 Page 02"
              }
            ]
          }
          
        ]
      },
      {
        "title": "Module Two",
        "visible": "true",
        "indexpage": "true",
        "lesson": [
          {
            "title": "Careers in Journalism",
            "num": "02.00",
            "time": "45",
            "points": "1",
            "page": [
              {
                "href": "../../module02/lesson00/02_00_01.htm",
                "title": "02.00 Page 01"
              },
              {
                "href": "../../module02/lesson00/02_00_02.htm",
                "title": "02.00 Page 02"
              }
            ]
          },
          {
            "title": "Career Research",
            "num": "02.01",
            "time": "90",
            "points": "25",
            "page": [
              {
                "href": "../../module02/lesson01/02_01_01.htm",
                "title": "02.01 Page 01"
              },
              {
                "href": "../../module02/lesson01/02_01_02.htm",
                "title": "02.01 Page 02"
              }
              
            ]
          
          }
        ]
      }
    ]
  }
}
</cfsavecontent>

<cfset tempObj = DeserializeJSON(json_text)>
<cfset xmlString = xmlObj.toXML(tempObj,'sitemap,module,lesson','title,visible,indexpage,num,time,points,href','sitemap,module,lesson,page')>
<!---  ---><cfdump var="#tempObj#">
<pre>
<code>
<cfoutput>#xmlString#</cfoutput>
</code>
</pre>


</body>
</html>