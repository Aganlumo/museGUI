from pylsl import StreamInlet, resolve_byprop

def main():
    print("Looking for a markers stream")
    streams = resolve_byprop('name', 'Markers')
    
    inlet = StreamInlet(streams[0])

    while True:
        sample, timestamp = inlet.pull_sample()
        print("Sample: {}, TimeStamp {}".format(sample, timestamp))


if __name__ == "__main__":
    main()