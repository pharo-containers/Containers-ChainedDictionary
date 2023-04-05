Class {
	#name : #CTChainedDictionaryTest,
	#superclass : #TestCase,
	#instVars : [
		'potentialParentEnvironment',
		'childEnvironment'
	],
	#category : #'Containers-ChainedDictionary'
}

{ #category : #accessing }
CTChainedDictionaryTest >> childEnvironment [
	^ childEnvironment
]

{ #category : #accessing }
CTChainedDictionaryTest >> childEnvironment: anObject [
	childEnvironment := anObject
]

{ #category : #helpers }
CTChainedDictionaryTest >> connectChildParent [
	self childEnvironment parent: self potentialParentEnvironment
]

{ #category : #resources }
CTChainedDictionaryTest >> environmentClass [
	^ CTChainedDictionary
]

{ #category : #accessing }
CTChainedDictionaryTest >> potentialParentEnvironment [
	^ potentialParentEnvironment
]

{ #category : #accessing }
CTChainedDictionaryTest >> potentialParentEnvironment: anObject [
	potentialParentEnvironment := anObject
]

{ #category : #resources }
CTChainedDictionaryTest >> setUp [
	self childEnvironment: self environmentClass new.
	self childEnvironment propertyAt: #P1inChildren put: 12.
	self childEnvironment propertyAt: #P2inChildren put: 13.
	self potentialParentEnvironment: self environmentClass new.
	self potentialParentEnvironment propertyAt: #P1inChildren put: 24.
	self potentialParentEnvironment propertyAt: #P0inParent put: 50
]

{ #category : #'tests-properties' }
CTChainedDictionaryTest >> testAllPropertiesInPresenceOfParent [
	| allP |
	self connectChildParent.
	allP := self childEnvironment allProperties keys.
	allP
		do: [ :each | 
			self
				assert:
					(#(#P0inParent #P1inChildren #P2inChildren #configurations)
						includes: each) ].
	allP := self potentialParentEnvironment allProperties keys.
	allP
		do: [ :each | 
			self assert: (#(#P0inParent #P1inChildren #configurations) includes: each) ]
]

{ #category : #'tests-properties' }
CTChainedDictionaryTest >> testAllPropertiesWithoutInheritance [

	| allP |
	allP := self childEnvironment allProperties keys.
	allP do: [ :each | self assert: (#(#P2inChildren #P1inChildren #configurations) includes: each) ].
	allP := self potentialParentEnvironment allProperties keys.
	allP do: [ :each | self assert: (#(#P0inParent #P1inChildren #configurations) includes: each) ]
]

{ #category : #'tests-lookup-dictionary' }
CTChainedDictionaryTest >> testAt [

	self childEnvironment at: #foo put: 'bar'.
	self assert: (self childEnvironment at: #foo) equals: 'bar'.
	self childEnvironment at: #foo put: 'baz'.
	self assert: (self childEnvironment at: #foo) equals: 'baz'.
	

]

{ #category : #'tests-lookup-dictionary' }
CTChainedDictionaryTest >> testAtAlsoLooksUpInParent [
	self connectChildParent.
	self
		assert: (self childEnvironment at: #P0inParent)
		equals: 50
]

{ #category : #'tests-lookup-dictionary' }
CTChainedDictionaryTest >> testAtIfAbsent [

	self assert: (self childEnvironment at: #foo put: 'bar') equals: 'bar'.
	self assert: (self childEnvironment at: #foo ifAbsent: [ 'baz' ]) equals: 'bar'.
	self assert: (self childEnvironment at: #bar ifAbsent: [ 'baz' ]) equals: 'baz'
]

{ #category : #'tests-lookup-dictionary' }
CTChainedDictionaryTest >> testAtIfAbsentDoesNotUseIfAbsentWhenPropertyIsDefinedInParent [
	self connectChildParent.
	"since the property P0inParent is defined in parent do not execute the ifAbsent: clause."
	self
		assert: (self childEnvironment at: #P0inParent ifAbsent: [ false ])
		equals: 50.
	self assert: (self childEnvironment at: #Zork ifAbsent: [ true ])
]

{ #category : #'tests-lookup-dictionary' }
CTChainedDictionaryTest >> testAtIfAbsentPut [
	
	self assert: (self childEnvironment at: #foo put: 'bar') equals: 'bar'.
	self assert: (self childEnvironment at: #foo) equals: 'bar'.
	
	self assert: (self childEnvironment at: #foo ifAbsentPut: [ 'baz' ]) equals: 'bar'.

	"ifAbsentPut: set the property with the put value"
	self assert: (self childEnvironment at: #bar ifAbsentPut: [ 'baz' ]) equals: 'baz'.
	self assert: (self childEnvironment at: #bar) equals: 'baz'
]

{ #category : #'tests-lookup-dictionary' }
CTChainedDictionaryTest >> testAtIfAbsentPutDoesNotUsePutWhenPropertyIsDefinedInParent [
	self connectChildParent.
	self
		assert: (self childEnvironment at: #P0inParent ifAbsentPut: [ false ])
		equals: 50.
	self
		assert: (self childEnvironment at: #Zork ifAbsentPut: [ true ]).
	self assert: (self childEnvironment at: #Zork) equals: true.
	self assert: (self childEnvironment includesLocalKey: #Zork).
	self deny: (self potentialParentEnvironment includesLocalKey: #Zork)
]

{ #category : #'tests-lookup-dictionary' }
CTChainedDictionaryTest >> testAtIfPresentIfAbsent [

	self assert: (self childEnvironment at: #foo put: 'bar') equals: 'bar'.
	self
		assert:
			(self childEnvironment
				at: #foo
				ifPresent: [ :smth | true ]
				ifAbsent: [ false ]).
	self
		deny:
			(self childEnvironment
				at: #foo2
				ifPresent: [ :smth | true ]
				ifAbsent: [ false ])
]

{ #category : #'tests-lookup-dictionary' }
CTChainedDictionaryTest >> testAtIfPresentIfAbsentInParent [
	self connectChildParent.
	self deny: (self childEnvironment includesLocalKey: #P0inParent).
	self assert: (self childEnvironment parent includesLocalKey: #P0inParent).
	self
		assert:
			(self childEnvironment
				at: #P0inParent
				ifPresent: [ :smth | true ]
				ifAbsent: [ false ])
]

{ #category : #'tests-lookup-dictionary' }
CTChainedDictionaryTest >> testAtPutDoesNotCannonizeKeyToBeASymbol [

	self childEnvironment at: #foo put: 'bar'.
	self assert: (self childEnvironment at: #foo) equals: 'bar'.
	self childEnvironment at: #foo put: 'baz'.
	self assert: (self childEnvironment at: #foo) equals: 'baz'.
	
	self childEnvironment at: 'foo2String' put: 'bar'.
	self assert: (self childEnvironment at: 'foo2String') equals: 'bar'.
	
	self childEnvironment at: 'foo3String' put: 'bar'.
	self assert: (self childEnvironment at: #'foo3String') equals: 'bar'.
]

{ #category : #'tests-lookup-dictionary' }
CTChainedDictionaryTest >> testChildrenAtOverridesParent [
	self connectChildParent.
	self
		assert: (self childEnvironment at: #P0inParent)
		equals: 50.
	self
		assert: (self childEnvironment at: #P1inChildren)
		equals: 12.
	self
		assert: (self childEnvironment parent at: #P1inChildren)
		equals: 24
]

{ #category : #'tests-lookup-properties' }
CTChainedDictionaryTest >> testChildrenPropertyAtOverridesParent [
	self connectChildParent.
	self
		assert: (self childEnvironment propertyAt: #P0inParent)
		equals: 50.
	self
		assert: (self childEnvironment propertyAt: #P1inChildren)
		equals: 12.
	self
		assert: (self childEnvironment parent propertyAt: #P1inChildren)
		equals: 24
]

{ #category : #'tests-lookup-properties' }
CTChainedDictionaryTest >> testChildrenPropertyOverridesParent [
	self connectChildParent.
	self
		assert: (self childEnvironment propertyAt: #P0inParent)
		equals: 50.
	self
		assert: (self childEnvironment propertyAt: #P1inChildren)
		equals: 12.
	self
		assert: (self childEnvironment parent propertyAt: #P1inChildren)
		equals: 24
]

{ #category : #'tests-copy' }
CTChainedDictionaryTest >> testCopyProperties [
	"I'm here to test if postCopy is right."

	| config |
	config := self environmentClass new.
	self deny: config properties == config copy properties
]

{ #category : #'tests-iteration' }
CTChainedDictionaryTest >> testDoWhenNoParent [

	| sum |
	sum := 0. 
	self potentialParentEnvironment do: [ :e | sum := e + sum ].
	self assert: sum equals: 74.
	sum := 0. 
	self childEnvironment do: [ :e | sum := e + sum ].
	self assert: sum equals: 25.
]

{ #category : #'tests-iteration' }
CTChainedDictionaryTest >> testDoWhenParent [
	
	| sum |
	self connectChildParent.
	sum := 0. 
	self potentialParentEnvironment do: [ :e | sum := e + sum ].
	self assert: sum equals: 74.
	sum := 0. 
	self childEnvironment do: [ :e | sum := e + sum ].
	self assert: sum equals: 25 + 74
]

{ #category : #'tests-properties' }
CTChainedDictionaryTest >> testFromDictionary [

	| dict env |
	dict := Dictionary new 
		at: #first put: 1;
		at: #second put: 2;
		yourself.
	
	env := CTChainedDictionary fromDictionary: dict. 
	
	self assert: (env at: #first) equals: 1.
	self assert: (env at: #second) equals: 2.
	self deny: env hasParent.
]

{ #category : #'tests-testing' }
CTChainedDictionaryTest >> testHasLocalProperty [

	self deny: (self childEnvironment hasLocalProperty: #foo).
	self childEnvironment propertyAt: #foo put: 'bar'.
	self assert: (self childEnvironment hasLocalProperty: #foo).
	self deny: (self childEnvironment hasLocalProperty: #bar).
	self deny: (self childEnvironment hasLocalProperty: #P0inParent).
	self assert: (self potentialParentEnvironment hasLocalProperty: #P0inParent).
]

{ #category : #'tests-testing' }
CTChainedDictionaryTest >> testHasParent [
	self connectChildParent.
	self deny: self potentialParentEnvironment hasParent.
	self assert: self childEnvironment hasParent
]

{ #category : #'tests-testing' }
CTChainedDictionaryTest >> testHasProperty [
	self connectChildParent.
	self assert: (self childEnvironment hasProperty: #P0inParent).
	self assert: (self childEnvironment hasProperty: #P1inChildren)
]

{ #category : #'tests-lookup-properties' }
CTChainedDictionaryTest >> testHasPropertyOnlyTestLocalProperties [

	self deny: (self childEnvironment hasLocalProperty: #foo).
	self childEnvironment propertyAt: #foo put: 'bar'.
	self assert: (self childEnvironment hasLocalProperty: #foo).
	self deny: (self childEnvironment hasLocalProperty: #bar).
	self deny: (self childEnvironment hasLocalProperty: #P0inParent).
	self assert: (self potentialParentEnvironment hasLocalProperty: #P0inParent).
]

{ #category : #'tests-lookup-dictionary' }
CTChainedDictionaryTest >> testIncludeKeyOnlyTestLocalProperties [

	self deny: (self childEnvironment includesLocalKey: #foo).
	self childEnvironment at: #foo put: 'bar'.
	self assert: (self childEnvironment includesLocalKey: #foo).
	self deny: (self childEnvironment includesLocalKey: #bar).
	self deny: (self childEnvironment includesLocalKey: #P0inParent).
	self assert: (self potentialParentEnvironment includesLocalKey: #P0inParent).
]

{ #category : #'tests-testing-dictionary' }
CTChainedDictionaryTest >> testIncludesKey [

	self connectChildParent.
	self assert: (self childEnvironment includesKey: #P0inParent).
	self assert: (self childEnvironment includesKey: #P1inChildren)
]

{ #category : #'tests-testing-dictionary' }
CTChainedDictionaryTest >> testIncludesLocalKey [

	self deny: (self childEnvironment includesLocalKey: #foo).
	self childEnvironment propertyAt: #foo put: 'bar'.
	self assert: (self childEnvironment includesLocalKey: #foo).
	self deny: (self childEnvironment includesLocalKey: #bar).
	self deny: (self childEnvironment includesLocalKey: #P0inParent).
	self assert: (self potentialParentEnvironment includesLocalKey: #P0inParent).
]

{ #category : #'tests-iteration' }
CTChainedDictionaryTest >> testKeysAndValuesDoWhenNoParent [
	
	| sum keys |
	sum := 0. 
	keys := Set new.
	self potentialParentEnvironment keysAndValuesDo: [ :k :v | sum := v + sum. keys add: k ].
	self assert: sum equals: 74.
	self assert: keys size equals: 2.
	self assert: (keys includes: #P0inParent).
	self assert: (keys includes: #P1inChildren).
	sum := 0. 
	keys := Set new.
	self childEnvironment keysAndValuesDo: [ :k :v | sum := v + sum. keys add: k ].
	self assert: sum equals: 25.
	self assert: keys size equals: 2.
	self assert: (keys includes: #P2inChildren).
	self assert: (keys includes: #P1inChildren).
]

{ #category : #'tests-iteration' }
CTChainedDictionaryTest >> testKeysAndValuesDoWhenParent [
	
	| sum keys |
	self connectChildParent.
	sum := 0. 
	keys := Set new.
	self potentialParentEnvironment keysAndValuesDo: [ :k :v | sum := v + sum. keys add: k ].
	self assert: sum equals: 74.
	self assert: keys size equals: 2.
	self assert: (keys includes: #P0inParent).
	self assert: (keys includes: #P1inChildren).
	sum := 0. 
	keys := Set new.
	self childEnvironment keysAndValuesDo: [ :k :v | sum := v + sum. keys add: k ].
	self assert: sum equals: 25 + 74.
	self assert: keys size equals: 3.
	self assert: (keys includes: #P2inChildren).
	self assert: (keys includes: #P1inChildren).
	self assert: (keys includes: #P0inParent).
]

{ #category : #'tests-iteration' }
CTChainedDictionaryTest >> testKeysWhenNoParent [

	self assert: (self childEnvironment keys includes: #P1inChildren).
	self assert: (self childEnvironment keys includes: #P2inChildren).
	self assert: self childEnvironment keys size equals: 2
]

{ #category : #'tests-iteration' }
CTChainedDictionaryTest >> testKeysWhenParent [
	"Keys of the parent should be returned too but without duplicates."
	self connectChildParent.
	self assert: (self childEnvironment keys includes: #P1inChildren).
	self assert: (self childEnvironment keys includes: #P2inChildren).
	self assert: (self childEnvironment keys includes: #P0inParent).
	self assert: self childEnvironment keys size equals: 3
]

{ #category : #'tests-properties' }
CTChainedDictionaryTest >> testPropertiesIsNotNil [
	self assert: self childEnvironment  properties notNil

]

{ #category : #'tests-lookup-properties' }
CTChainedDictionaryTest >> testPropertyAt [

	self childEnvironment  propertyAt: #foo put: 'bar'.
	self assert: (self childEnvironment propertyAt: #foo) equals: 'bar'.
	self childEnvironment propertyAt: #foo put: 'baz'.
	self assert: (self childEnvironment propertyAt: #foo) equals: 'baz'.
	

]

{ #category : #'tests-lookup-properties' }
CTChainedDictionaryTest >> testPropertyAtAlsoLooksUpInParent [
	self connectChildParent.
	self
		assert: (self childEnvironment propertyAt: #P0inParent)
		equals: 50
]

{ #category : #'tests-lookup-properties' }
CTChainedDictionaryTest >> testPropertyAtIfAbsent [

	self assert: (self childEnvironment propertyAt: #foo put: 'bar') equals: 'bar'.
	self assert: (self childEnvironment propertyAt: #foo ifAbsent: [ 'baz' ]) equals: 'bar'.
	self assert: (self childEnvironment propertyAt: #bar ifAbsent: [ 'baz' ]) equals: 'baz'
]

{ #category : #'tests-lookup-properties' }
CTChainedDictionaryTest >> testPropertyAtIfAbsentDoesNotUseIfAbsentWhenPropertyIsDefinedInParent [
	self connectChildParent.
	"since the property P0inParent is defined in parent do not execute the ifAbsent: clause."
	self
		assert: (self childEnvironment propertyAt: #P0inParent ifAbsent: [ false ])
		equals: 50.
	self assert: (self childEnvironment propertyAt: #Zork ifAbsent: [ true ])
]

{ #category : #'tests-lookup-properties' }
CTChainedDictionaryTest >> testPropertyAtIfAbsentPut [
	
	self assert: (self childEnvironment propertyAt: #foo put: 'bar') equals: 'bar'.
	self assert: (self childEnvironment propertyAt: #foo) equals: 'bar'.
	
	self assert: (self childEnvironment propertyAt: #foo ifAbsentPut: [ 'baz' ]) equals: 'bar'.

	"ifAbsentPut: set the property with the put value"
	self assert: (self childEnvironment propertyAt: #bar ifAbsentPut: [ 'baz' ]) = 'baz'.
	self assert: (self childEnvironment propertyAt: #bar) = 'baz'
]

{ #category : #'tests-lookup-properties' }
CTChainedDictionaryTest >> testPropertyAtIfAbsentPutDoesNotUsePutWhenPropertyIsDefinedInParent [
	self connectChildParent.
	self
		assert: (self childEnvironment propertyAt: #P0inParent ifAbsentPut: [ false ])
		equals: 50.
	self
		assert: (self childEnvironment propertyAt: #Zork ifAbsentPut: [ true ]).
	self assert: (self childEnvironment propertyAt: #Zork) equals: true.
	self assert: (self childEnvironment hasLocalProperty: #Zork).
	self deny: (self potentialParentEnvironment hasLocalProperty: #Zork)
]

{ #category : #'tests-lookup-properties' }
CTChainedDictionaryTest >> testPropertyAtIfPresentIfAbsent [

	self assert: (self childEnvironment propertyAt: #foo put: 'bar') equals: 'bar'.
	self
		assert:
			(self childEnvironment
				propertyAt: #foo
				ifPresent: [ :smth | true ]
				ifAbsent: [ false ]).
	self
		deny:
			(self childEnvironment
				propertyAt: #foo2
				ifPresent: [ :smth | true ]
				ifAbsent: [ false ])
]

{ #category : #'tests-lookup-properties' }
CTChainedDictionaryTest >> testPropertyAtIfPresentIfAbsentInParent [
	self connectChildParent.
	self deny: (self childEnvironment hasLocalProperty: #P0inParent).
	self assert: (self childEnvironment parent hasLocalProperty: #P0inParent).
	self
		assert:
			(self childEnvironment
				propertyAt: #P0inParent
				ifPresent: [ :smth | true ]
				ifAbsent: [ false ])
]

{ #category : #'tests-lookup-properties' }
CTChainedDictionaryTest >> testPropertyAtPutDoesNotCannonizeKeyToBeASymbol [

	self childEnvironment propertyAt: #foo put: 'bar'.
	self assert: (self childEnvironment propertyAt: #foo) equals: 'bar'.
	self childEnvironment propertyAt: #foo put: 'baz'.
	self assert: (self childEnvironment propertyAt: #foo) equals: 'baz'.
	
	self childEnvironment propertyAt: 'foo2String' put: 'bar'.
	self assert: (self childEnvironment propertyAt: 'foo2String') equals: 'bar'.
	
	self childEnvironment propertyAt: 'foo3String' put: 'bar'.
	self assert: (self childEnvironment propertyAt: #'foo3String') equals: 'bar'.
]

{ #category : #'tests-iteration' }
CTChainedDictionaryTest >> testValuesDoWhenNoParent [

	| sum |
	sum := 0. 
	self potentialParentEnvironment valuesDo: [ :e | sum := e + sum ].
	self assert: sum equals: 74.
	sum := 0. 
	self childEnvironment valuesDo: [ :e | sum := e + sum ].
	self assert: sum equals: 25.
]

{ #category : #'tests-iteration' }
CTChainedDictionaryTest >> testValuesDoWhenParent [
	
	| sum |
	self connectChildParent.
	sum := 0. 
	self potentialParentEnvironment valuesDo: [ :e | sum := e + sum ].
	self assert: sum equals: 74.
	sum := 0. 
	self childEnvironment valuesDo: [ :e | sum := e + sum ].
	self assert: sum equals: 25 + 74
]
