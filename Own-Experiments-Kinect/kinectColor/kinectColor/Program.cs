using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Kinect;
using System.Drawing;
using System.Windows.Media.Imaging;
using System.Windows;
using System.IO;

namespace kinectColor
{
    class Program
    {
        static void Main(string[] args)
        {
            myKinect k1;
            k1 = new myKinect();
            k1.initialize();
            Console.ReadKey();
        }
    }

    public class myKinect
    {
        //variables
        public KinectSensor sensor = null;
        public byte[] colorPixels;
        public int[] colorPixelsInt;
        public DepthImagePixel[] depthPixels;
        public int[] depthinmm;
        public Skeleton[] skelData;
        public string filenamec = @"C:\Users\Manjari\Documents\MATLAB\colorData.txt";
        public string filenamed = @"C:\Users\Manjari\Documents\MATLAB\depthData.txt";
        public string filenames = @"C:\Users\Manjari\Documents\MATLAB\skeletonData.txt";
    
        public void initialize()
        {
            //Ennumerate Kinect sensors
            foreach (KinectSensor potentialSensor in KinectSensor.KinectSensors)
            {
                if (potentialSensor.Status == KinectStatus.Connected)
                {
                    this.sensor = potentialSensor;
                    Console.WriteLine("Sensor Initialized!");
                    break;
                }
            }
            //check if kinect available
            if (this.sensor == null)
                Console.WriteLine("Kinect not connected. Check connection and retry.");
            else
            {
                //---Enable data streaming and start the kinect                
                this.sensor.ColorStream.Enable(ColorImageFormat.RgbResolution640x480Fps30);
                this.sensor.DepthStream.Enable(DepthImageFormat.Resolution640x480Fps30);
                this.sensor.SkeletonStream.Enable();
                this.sensor.Start();
                this.sensor.ElevationAngle = 
                //---allocate data for storage
                this.colorPixels = new byte[this.sensor.ColorStream.FramePixelDataLength];
                this.colorPixelsInt = new int[this.sensor.ColorStream.FramePixelDataLength];
                this.depthPixels = new DepthImagePixel[this.sensor.DepthStream.FramePixelDataLength];
                this.depthinmm = new int[this.sensor.DepthStream.FramePixelDataLength];
                this.skelData = new Skeleton[this.sensor.SkeletonStream.FrameSkeletonArrayLength];
                if(this.sensor.SkeletonStream!=null)
                {
                    this.sensor.SkeletonStream.AppChoosesSkeletons = true;
                    this.sensor.SkeletonStream.ChooseSkeletons();
                }
                //---register an event that fires when all frames data is ready
                this.sensor.AllFramesReady += this.SensorAllFrameReady;
            }
        }

        //Fire when all frames ready
        private void SensorAllFrameReady(object sender, AllFramesReadyEventArgs e)
        {
            Console.WriteLine("Call to all frames ready event handler");
            using (ColorImageFrame colorFrame = e.OpenColorImageFrame())
            {
                if (colorFrame != null)
                {
                    colorFrame.CopyPixelDataTo(this.colorPixels);
                    for (int i = 0; i < 4 * 307200; i++)
                        colorPixelsInt[i] = colorPixels[i];
                    //write to file             
                    using (StreamWriter swc = new StreamWriter(filenamec,true))
                    { 
                        for (int i = 0; i < 4 * 307200; i++)
                        {
                            if (colorPixelsInt[i] != 0)
                                swc.Write(colorPixelsInt[i]);
                            swc.Write(" ");
                            if ((i + 1) % 4 == 0)
                                swc.Write("\n");
                         }
                    }    
                }
            }
            using (DepthImageFrame depthFrame = e.OpenDepthImageFrame())
            {
                if (depthFrame != null)
                {
                    depthFrame.CopyDepthImagePixelDataTo(this.depthPixels);
                    for (int i = 0; i < 307200; i++)
                        depthinmm[i] = depthPixels[i].Depth;
                    //write to file
                    using (StreamWriter swd = new StreamWriter(filenamed, true))
                    { 
                        for (int i = 0; i < 307200; i++)
                        {
                            swd.Write(depthinmm[i]);
                            swd.Write("\n");
                        }
                    }
                }
            }
            using (SkeletonFrame skelFrame = e.OpenSkeletonFrame())
            {
                if (skelFrame != null)
                {
                    skelFrame.CopySkeletonDataTo(this.skelData);
                    foreach (Skeleton skeleton in this.skelData)
                    {
                        if (skeleton.TrackingState == SkeletonTrackingState.Tracked)
                        {
                            Joint j = skeleton.Joints[JointType.ElbowLeft];

                            if (j.TrackingState == JointTrackingState.Tracked)
                            {
                                Console.WriteLine("Left elbow: " + j.Position.X + ", " + j.Position.Y + ", " + j.Position.Z);
                            }
                        }
                        else if (skeleton.TrackingState == SkeletonTrackingState.PositionOnly)
                        {
                            //write to file
                            using (StreamWriter sws = new StreamWriter(filenames, true))
                            {
                                sws.Write(skeleton.Position.X);
                                sws.Write(" ");
                                sws.Write(skeleton.Position.Y);
                                sws.Write(" ");
                                sws.Write(skeleton.Position.Z);
                                sws.Write("\n");
                            }
                        }
                    }
                    //write to file
                }
            }
            

       }


    }
}
