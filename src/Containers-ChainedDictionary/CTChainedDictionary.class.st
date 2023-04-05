"
I'm a kind of dictionary with optional lookup in my parent. I'm an environment of properties with values (binding key -> value). I may have an ancestor chain (father, grand-father...) in which I look for my properties when I do not define them. 

Users should pay attention than getting keys is not the same as iterating on keys since a parent may have the same keys than a child. Therefore the iteration will iterate all the keys/values while getting the keys will return a set of the unique keys and not an array with potential duplicates because from the client of a child it is not possible to access a shadowed keys in a parent.


Implementation notes.

For the moment keysDo: do not garantee any order. A possible improvement would be to use an orderedUniqueCollection to keep the keys. 

"
Class {
	#name : #CTChainedDictionary,
	#superclass : #Object,
	#instVars : [
		'parent',
		'properties'
	],
	#category : #'Containers-ChainedDictionary'
}

{ #category : #examples }
CTChainedDictionary class >> childEnvironmentExample [
	<sampleInstance>
	^ self new
		propertyAt: #P1inChildren put: 12;
		propertyAt: #P2inChildren put: 13; yourself
]

{ #category : #examples }
CTChainedDictionary class >> childEnvironmentWithParentExample [
	<sampleInstance>
	^ self childEnvironmentExample parent: self parentEnvironmentExample ; yourself
]

{ #category : #'instance creation' }
CTChainedDictionary class >> fromDictionary: aDictionary [

	| inst |
	inst := self new. 
	aDictionary keysAndValuesDo: [ :k :v | inst at: k put: v ].
	^ inst
	
]

{ #category : #examples }
CTChainedDictionary class >> parentEnvironmentExample [
	<sampleInstance>
	^ self new
		propertyAt: #P1inChildren put: 24;
		propertyAt: #P0inParent put: 50 ; yourself
]

{ #category : #conversion }
CTChainedDictionary >> allProperties [
	"Answer all properties of the receiver and its parents."
	"This method should be removed.... or at least should return a CTEnvironment"
	| parentProperties |
	parentProperties := self hasParent
		ifTrue: [ parent allProperties ]
		ifFalse: [ Dictionary new ].
	parentProperties addAll: self properties.
	"addAll: is not in the current API of environment"
	^ parentProperties
]

{ #category : #conversion }
CTChainedDictionary >> asFlatDictionary [
	"Answer a new  of the receiver and its parents."

	^ self flattenIn: Dictionary new
]

{ #category : #'accessing - dictionary' }
CTChainedDictionary >> at: aKey [
	"Answer the value of the property ==aKey==, potentially looking in the parent, raises an error if the property doesn't exist."


	^ properties
		at: aKey asSymbol
		ifAbsent: [ self hasParent
				ifTrue: [ parent at: aKey ]
				ifFalse: [ self errorPropertyNotFound: aKey ] ]
]

{ #category : #'accessing - dictionary' }
CTChainedDictionary >> at: aKey ifAbsent: aBlock [
	"Answer the value of the property ==aKey==, potentially looking in parents, or the result of ==aBlock== if the property doesn't exist."

	^ properties
		at: aKey asSymbol
		ifAbsent: [ self hasParent
				ifTrue: [ parent at: aKey ifAbsent: aBlock ]
				ifFalse: aBlock ]
]

{ #category : #'accessing - dictionary' }
CTChainedDictionary >> at: aKey ifAbsentPut: aBlock [
	"Answer the value of the property ==aKey==, potentially defined in parents, or if the property doesn't exist adds and answers the result of evaluating ==aBlock==."

	"We look up first to know and once we know if the property is not defined somewhere, then we set it. We do it like that to avoid to execute the put block on the parent because the put should be executed on the child."
	^ (self hasProperty: aKey)
			ifTrue: [ self at: aKey ]
			ifFalse: [ self at: aKey put: aBlock value ]
]

{ #category : #'accessing - dictionary' }
CTChainedDictionary >> at: aKey ifPresent: presentBlock ifAbsent: absentBlock [
	"Answer the result of ==presentBlock== if I have the property ==aKey==, in the receiver or its parents or the result of ==absentBlock==."

	^ (self hasProperty: aKey)
			ifTrue: [ presentBlock value: (self at: aKey) ]
			ifFalse: [ absentBlock value ]
]

{ #category : #'accessing - dictionary' }
CTChainedDictionary >> at: aKey put: aValue [
	"Adds or replaces the property ==aKey== with ==aValue== in the receiver."

	^ properties at: aKey asSymbol put: aValue
]

{ #category : #iteration }
CTChainedDictionary >> do: aBlock [ 
	"Evaluate aBlock for each of the receiver's values, starting from the receiver and going up in its parent chain if any."

	self valuesDo: aBlock
]

{ #category : #error }
CTChainedDictionary >> errorPropertyNotFound: aKey [ 

	KeyNotFound signal: aKey
]

{ #category : #conversion }
CTChainedDictionary >> flattenIn: aDictionable [
	"Answer a new aDictionable of the receiver and its parents."

	self hasParent
		ifTrue: [ parent flattenIn: aDictionable ].
	aDictionable addAll: properties.
	^ aDictionable
]

{ #category : #testing }
CTChainedDictionary >> hasLocalProperty: aKey [
	"Test if the property ==aKey== is defined within the receiver, not checking potential parent."

	^ properties includesKey: aKey asSymbol
]

{ #category : #testing }
CTChainedDictionary >> hasParent [
	^ parent notNil
]

{ #category : #testing }
CTChainedDictionary >> hasProperty: aKey [
	"Answer true iff I (or one of my ancestors) contain a property named ==aKey==."

	^ properties
		at: aKey asSymbol
		ifPresent: [ :value | true ]
		ifAbsent: [ self hasParent
				ifTrue: [ parent hasProperty: aKey ]
				ifFalse: [ false ] ]
]

{ #category : #'testing-dictionary' }
CTChainedDictionary >> includesKey: aKey [
	"Answer true iff I (or one of my ancestors) contain a property named ==aKey==."

	^ properties
		at: aKey asSymbol
		ifPresent: [ :value | true ]
		ifAbsent: [ self hasParent
				ifTrue: [ parent includesKey: aKey ]
				ifFalse: [ false ] ]
]

{ #category : #'testing-dictionary' }
CTChainedDictionary >> includesLocalKey: aKey [
	"Test if the property ==aKey== is defined within the receiver, not checking potential parent."

	^ properties includesKey: aKey asSymbol
]

{ #category : #initialization }
CTChainedDictionary >> initialize [
	super initialize.
	properties := OrderedDictionary new.
]

{ #category : #accessing }
CTChainedDictionary >> keys [
	"Answer a Set containing the receiver's keys."
	| s |
	s := Set new. 
	"we use a set and not an array because we should go over potential parent keys and the intersection between parent and children keys may not be empty. So we should not report duplicates."
	self keysDo: [ :k | s add: k ].
	^ s 
]

{ #category : #iteration }
CTChainedDictionary >> keysAndValuesDo: aBlock [ 
	"Evaluate aBlock for each of the receiver's keys and values, starting from the receiver and going up in its parent chain if any."

	properties keysAndValuesDo: aBlock.
	self hasParent ifTrue: [ parent keysAndValuesDo: aBlock ]
	
]

{ #category : #iteration }
CTChainedDictionary >> keysDo: aBlock [ 
	"Evaluate aBlock for each of the receiver's keys, starting from the receiver and going up in its parent chain if any."

	properties keysDo: aBlock.
	self hasParent ifTrue: [ parent keysDo: aBlock ]
	
]

{ #category : #accessing }
CTChainedDictionary >> parent [
	"A parent is a Configuration I extends"
	
	^ parent
]

{ #category : #accessing }
CTChainedDictionary >> parent: anEnvironment [
	parent := anEnvironment
]

{ #category : #copying }
CTChainedDictionary >> postCopy [
	"Make sure that properties are properly copied, but not the parent."
	super postCopy.
	properties := properties copy.

]

{ #category : #private }
CTChainedDictionary >> properties [

	^ properties
]

{ #category : #'accessing - properties' }
CTChainedDictionary >> propertyAt: aKey [
	"Answer the value of the property ==aKey==, potentially looking in the parent, raises an error if the property doesn't exist."

	^ self at: aKey
]

{ #category : #'accessing - properties' }
CTChainedDictionary >> propertyAt: aKey ifAbsent: aBlock [
	"Answer the value of the property ==aKey==, potentially looking in parents, or the result of ==aBlock== if the property doesn't exist."

	^ self at: aKey ifAbsent: aBlock
]

{ #category : #'accessing - properties' }
CTChainedDictionary >> propertyAt: aKey ifAbsentPut: aBlock [
	"Answer the value of the property ==aKey==, potentially defined in parents, or if the property doesn't exist adds and answers the result of evaluating ==aBlock==."

	"We look up first to know and once we know if the property is not defined somewhere, then we set it. We do it like that to avoid to execute the put block on the parent because the put should be executed on the child."
	^ self at: aKey ifAbsentPut: aBlock
]

{ #category : #'accessing - properties' }
CTChainedDictionary >> propertyAt: aKey ifPresent: presentBlock ifAbsent: absentBlock [
	"Answer the result of ==presentBlock== if I have the property ==aKey==, in the receiver or its parents or the result of ==absentBlock==."

	^ self at: aKey ifPresent: presentBlock ifAbsent: absentBlock
]

{ #category : #'accessing - properties' }
CTChainedDictionary >> propertyAt: aKey put: aValue [
	"Adds or replaces the property ==aKey== with ==aValue== in the receiver."

	^ self at: aKey put: aValue
]

{ #category : #iteration }
CTChainedDictionary >> valuesDo: aBlock [
	"Evaluate aBlock for each of the receiver's values, starting from the receiver and going up in its parent chain if any."
	
	properties valuesDo: aBlock.
	self hasParent ifTrue: [ parent valuesDo: aBlock ]
	
]
