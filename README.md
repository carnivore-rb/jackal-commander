# Jackal Commander

Execute actions via jackal

## Usage

Set action to execute within payload:


### Single action

```json
{
  ...
  "data": {
    "commander": {
      "action": "toucher"
    }
  }
}
```

### Multiple actions


```json
{
  ...
  "data": {
    "commander": {
      "actions": [
        "toucher",
        "remover"
      ]
    }
  }
}
```

### Mixed actions

```json
{
  ...
  "data": {
    "commander": {
      "action": "toucher",
      "actions": [
        "remover"
      ]
    }
  }
}
```

### With extra arguments

```json
{
  ...
  "data": {
    "commander": {
      "action": {
        "name": "custom_touch",
        "arguments": "/tmp/my-custom-file"
      }
    }
  }
}
```

## Configuration

Define the action within the configuration:

```json
{
  ...
  "config": {
    "actions": {
      "toucher": "touch /tmp/test-file",
      "remover": "rm -f /tmp/test-file",
      "custom_touch": "touch"
    }
  }
}
```

## Info

* Repository: https://github.com/carnviore-rb/jackal-cfn
* IRC: Freenode @ #carnivore
