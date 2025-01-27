from rest_framework import serializers

#serializers are very similar to django forms
# also validates data
class HelloSerializer(serializers.Serializer):
    """Serializes a name field for testing our API View"""
    name =serializers.CharField(max_length=10)
