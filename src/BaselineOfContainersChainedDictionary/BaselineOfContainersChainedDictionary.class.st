Class {
	#name : #BaselineOfContainersChainedDictionary,
	#superclass : #BaselineOf,
	#category : #BaselineOfContainersChainedDictionary
}

{ #category : #baselines }
BaselineOfContainersChainedDictionary >> baseline: spec [
	<baseline>

	spec for: #pharo do: [		
		spec 
			package: 'Containers-ChainedDictionary'.
		]
]
