# DAVID
A tool for interactive visual exploration of complex linked data. 

DAVID uses component based visualization to allow for creative development and exploration of complex, linked data in a web environment. It is capable of visualizing big data on demand and creating multi-machine visualizations via event synchronization between machines. Visual components are extendable and running in their own logical containers. Seperation of concerns is enforced bia language seperation. Programming against DAVID as a designer require Javscript knowledge and your vis library of choice. The logic of the application is written in googles DART language.

![DAVID explore session](/doc/img/explore.png)

### Running DAVID
* You will require Dartium to run DAVID. Make sure you run a pub install before starting the system. While DAVID is actively maintained I do not have the time to update its internals to the most current version of dart and its dependencies. It was developed against DART SDK 36647.
* The nativ shell (access to OS files and pSQL) is written in node and located in the core data package. Fire up shell.js to get access to critical resources (again, this is OS level and can harm your system, depending on you extensions).

###What is DAVID (Dynamic Analysis and Visualization of Interconnected Data) ?
In the age of big data, very large sets of different measurable data are permanently acquired. However, the development of efficient methodology to search for and identify the actual information hidden in large data sets, and to explore relationships between sub-datasets, is lagging behing. Data visualization is an efficient and intuitively accessible approach to identify patterns in large and diverse data sets. State-of-the-art computing provides the enabling technology to visualize data not only as static images but also in interactive visualizations. But even the most efficient and powerful data visualization tools do not satisfactorily address and exploit the possibilities of interactive data analysis. They constrain creativity and are often complex to use. We propose to use "component based visualization" for interactive data exploration. Component based visualization derives properties such as "composability" and "information hiding" from the concept of a software component and transfers them to the domain of data visualization. By building a directed graph of such components, a complex set of visualizations can be composed. The dataset of a component itself can then be used as a parameter to define the semantics of an arc between two components (e.g. two visualizations can be connected to show the same GPS coordinate from different data recordings, thus allowing the comparison of other associated data, such as a heart rate).
![DAVID explore session](/doc/img/running.png)
Additionally, users are allowed to not only interact with the visualization but also alter data processing and visualization by a component. This approach allows simultaneous exploration of multiple datasets applying various criteria, while comprising the relationships between the data. This concept is showcased through a visualization system that allows the user not only to dive into data via visualizations, but facilitates the creative freedom to build, extend and define new visualizations and their composition. The prototype, called DAVID (dynamic analysis and visualization of integrated data), is a tool for interactive exploration of linked data.

### Loading data
To load data into DAVID one of two views have to be addressed. As an analyst one needs to open the view creator (new view in the left sidebar). Creating a new view on multiple sets of complex data is a easy. The following picture shows the creation of a:
0) Selecting a repository of data. This is predefined in DAVID and creating a new one for your company / project needs expert knowledge (see the other viewpoint.)
1) Query
2) A visualization
3) A automatically generated function to map the data to the visualization
4) Multiple (not expanded) ways to alter data fetching, mapping, transformation etc.

Clicking the add button adds the configuration to the stack of visualizations. Once saved, these visualizations can be used (and executed) from the library view (Library in the left sidebar).

![creation of a dataview in DAVID](/doc/img/load.png)
The second view is the programmer who is concerned with creating repositories. This needs extension of the "Repository" class inside DAVID, in the data package. A couple of simple definitions (please see the source code) and signatures add a new repository to DAVID. Data fetching is a task that can be done via the native-shell (FS, SQL, CSV), or via an own technique (web sockets, for example are already implemented as a data source.).

### Acknowledgments
This work was initiate as part of Alexander Waldmanns Masters Thesis Research conducted at the Massachusetts Institute of Technology AgeLab and supervised by Prof. Brügge (TUM). Support for this work was provided in part by the US DOT’s Region I New England University Transportation Center at MIT and the Toyota Class Action Settlement Safety Research and Education Program. The views and conclusions being expressed are those of the authors, and have not been sponsored, approved, or endorsed by Toyota or plaintiffs’ class counsel. Acknowledgment is also extended to The Santos Family Foundation and Toyota’s CSRC for providing funding for the data which stimulated the need for developing new visualization tools.
