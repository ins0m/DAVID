part of visualizer;
class MetricLibrary {

  static String defaultMetric = "// need a function";
  static String defaultManipulator = "// need a function";
  static String deaultReverseMetric = "// need a function";

  String dataMetric = defaultMetric;
  String dataManipulator = defaultManipulator;
  String reverseDataMetric = deaultReverseMetric;

  /**
  * This metric will work for most of the sources! If not, overwrite it
  */
  String DEFAULT_MANIPULATOR = """
    function (context, data) {
      // the visualization is available via _self_
      return data
    }
    """;

  String createHighchartsManipulator(List groupNamePair, List timestampNamePair, List val1NamePair, {List val2NamePair, List val3NamePair, List val4NamePair}){
    return """
    function (context, data) {
    // For the currently used standard-implementation based on highcharts, data has to have to following format:
		// [{
		// 		name: 'Subject1,
		// 		data: [ {x: x, y: y}, {x: x, y: y} ]
		// 	}, {
		// 		name: 'Subject2,
		// 		data: [ {x: x, y: y}, {x: x, y: y} ]
		// 	}]
      var rootArr = [];
      data.forEach(function (givenData){
        var hit = false;
        rootArr.forEach( function(dataObject){
          if (dataObject.${groupNamePair[0]}==givenData.${groupNamePair[1]}){
            dataObject.data.push(
                {
                ${timestampNamePair[0]}: parseFloat(givenData.${timestampNamePair[1]}),
                ${val1NamePair[0]}: parseFloat(givenData.${val1NamePair[1]})
                  ${(val2NamePair!=null && val2NamePair.length==2 ? ", ${val2NamePair[0]}:parseFloat(givenData.${val2NamePair[1]})" : "" )}
                  ${(val3NamePair!=null && val3NamePair.length==2 ? ", ${val3NamePair[0]}:parseFloat(givenData.${val3NamePair[1]})" : "" )}
                  ${(val4NamePair!=null && val4NamePair.length==2 ? ", ${val4NamePair[0]}:parseFloat(givenData.${val4NamePair[1]})" : "" )}}
            );
            hit = true;
          }
        });
        if (!hit){
          // we are in our initial run: Set up the base data offest:
          context.currentTimeCache = parseFloat(givenData.${timestampNamePair[1]});
          rootArr.push({
              ${groupNamePair[0]}: givenData.${groupNamePair[1]},
              data: [
                {
                ${timestampNamePair[0]}: parseFloat(givenData.${timestampNamePair[1]}),
                ${val1NamePair[0]}: parseFloat(givenData.${val1NamePair[1]})
                  ${(val2NamePair!=null && val2NamePair.length==2 ? ", ${val2NamePair[0]}:parseFloat(givenData.${val2NamePair[1]})" : "" )}
                  ${(val3NamePair!=null && val3NamePair.length==2 ? ", ${val3NamePair[0]}:parseFloat(givenData.${val3NamePair[1]})" : "" )}
                  ${(val4NamePair!=null && val4NamePair.length==2 ? ", ${val4NamePair[0]}:parseFloat(givenData.${val4NamePair[1]})" : "" )}}
              ]
          });
        }
      });
      return rootArr;
    }
    """;
  }

  String createHighchartsMetric(List timestampNamePair, {List val1NamePair, List val2NamePair, List val3NamePair, List val4NamePair}){
    return """
      function (context, val) {
        var result = [];
          context.data.forEach(function(dataGroup){
            var currentData = {
              name: dataGroup.name,
              data : []}
            dataGroup.data.forEach( function(dataObject, i){
                // console.log("value:"+JSON.stringify(dataObject));
              if ( dataGroup.data.length >= i+1 && dataObject.${timestampNamePair[0]} <= val && dataGroup.data[i+1].${timestampNamePair[0]} > val){
                currentData.data.push(dataObject);
                // console.log("value hit:"+JSON.stringify(dataObject));
              }
            })
            result.push(currentData);
          });
          if (result.length>0 && result[0].data.length>0){
            return result[0].data[0]
          }
        return result;
      }
      """;
  }

  String createHighchartsReverseMetric(List timestampNamePair, List val1NamePair, confidence, { List val2NamePair, List val3NamePair, List val4NamePair}){
    return """
      function (context, datapoint) {
        // find the datapoint with the values and return the time
        for (var j=0;j<context.data.length;j++){
          currentData = context.data[j];
          for (var i=0;i<currentData.data.length;i++){
            var currentDataPoint = currentData.data[i];
            // this does not really help, since x is the time, but for a plot that has, for example a distance, this reverse function
            // will ignore the time !
            // console.log(JSON.stringify(currentDataPoint.${val1NamePair[0]})+" - "+ datapoint.${val1NamePair[0]});
            if (
                                                                   Math.abs(currentDataPoint.${val1NamePair[0]} - datapoint.${val1NamePair[0]})<${confidence}
            ${(val2NamePair!=null && val2NamePair.length==1 ? "&&  Math.abs(currentDataPoint.${val2NamePair[0]} - datapoint.${val2NamePair[0]})<${confidence}" : "" )}
            ${(val3NamePair!=null && val3NamePair.length==1 ? "&&  Math.abs(currentDataPoint.${val3NamePair[0]} - datapoint.${val3NamePair[0]})<${confidence}" : "" )}
            ${(val4NamePair!=null && val4NamePair.length==1 ? "&&  Math.abs(currentDataPoint.${val4NamePair[0]} - datapoint.${val4NamePair[0]})<${confidence}" : "" )}
            ){
              return currentDataPoint.${timestampNamePair[0]};
            }
          }
        }
      }
      """;
  }

  String createDefaultMetric(xName, yName){
    return """
      function (context, val) {
        return {
          x: context.data[val]['$xName'],
          y: context.data[val]['$yName']
        }
      }
      """;
  }

  String createDefaultReverseMetric(){
    return """
      function (context, datapoint) {
        // find the datapoint with the values and return the time
        context.data.forEach(function(currentDataPoint,index){
        // this does not really help, since x is the time, but for a plot that has, for example a distance, this reverse function
        // will ignore the time !
          if (currentDataPoint.x == datapoint.x && currentDataPoint.y == datapoint.y){
            return index
            }
        })
      }
      """;
  }

  String createTableMetric = """
    function (context, val) {
      var item = [];
      for (var prop in val) {
          item.push(val[prop]);
      }
      return item
    }
    """;

  String createTableReverseMetric = """
    function (context, arr) {
      this.data.forEach(function(currentDataPoint,index){
              var foundAnEntry = 0;
              for (var prop in currentDataPoint) {
                  arr.forEach(function(arrEntry){
                    if (arrEntry == currentDataPoint[prop]){
                      foundAnEntry++;
                    }
                  })
              }
              if (foundAnEntry == arr.length){
                return currentDataPoint.time // ? assuming that this is the name in the fetched result
              }
            }
        })
    }
    """;

  String createTableManipulator(List groupNamePair, List timestampNamePair, List val1NamePair){
    return """
    function (context, data) {
      var header = [];
      for (var prop in data[0]){
          header.push({"sTitle":prop});
      }
      // console.log(data[0]);
      // console.log(header);

      context.currentTimeCache = parseFloat(data[0].${timestampNamePair[1]});

      return {
        header:header,
        items:data
      }
    }
    """;
  }


  MetricLibrary(){}
}
