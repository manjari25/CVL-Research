using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Microsoft.Kinect;
using Coding4Fun.Kinect.Wpf;
using System.Drawing;
using System.IO;
using System.Globalization;

namespace kinectData
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        //---SENSOR AND MISC. DATA STRUCTURES + COUNTERS

        /// <summary>
        /// Flag indicating start of capture
        /// </summary>
        private bool flagCapture = true;
        /// <summary>
        /// Name of the files stored to disk
        /// </summary>
        private static int i = 1;
        /// <summary>
        /// /// <summary>
        /// Count indicating number of joints in the body
        /// </summary>
        private static int countJ = 20;
        /// Flag indicating whether done storing RGB,D,Skeleton data
        /// </summary>
        private static bool done = false;
        /// <summary>
        /// String for storing name of folder for color images
        /// </summary>
        private static string colorFolder = @"C:\Users\Manjari\Documents\MATLAB\Project\Data\Color\";
        /// <summary>
        /// String for storing name of folder for depth images
        /// </summary>
        private static string depthFolder = @"C:\Users\Manjari\Documents\MATLAB\Project\Data\Depth\";
        /// <summary>
        /// String for storing name of file for color images
        /// </summary>
        private static string colorPath = @"C:\Users\Manjari\Documents\MATLAB\Project\Data\colorData.txt";
        /// <summary>
        /// String for storing name of file for depth images
        /// </summary>
        private static string depthPath = @"C:\Users\Manjari\Documents\MATLAB\Project\Data\depthData.txt";
        /// <summary>
        /// String for storing name of file for depth images in mm
        /// </summary>
        private static string depthPathInMm = @"C:\Users\Manjari\Documents\MATLAB\Project\Data\depthDataInMm.txt";
        /// <summary>
        /// String for storing name of file for skeleton images
        /// </summary>
        private static string skeletonPath = @"C:\Users\Manjari\Documents\MATLAB\Project\Data\skeletonData3D.txt";
        /// <summary>
        /// Active Kinect sensor
        /// </summary>
        private KinectSensor sensor = null;

        //---RGB DATA STRUCTURES

        /// <summary>
        /// Bitmap that will hold color information
        /// </summary>
        private WriteableBitmap colorBitmap;

        /// <summary>
        /// Intermediate storage for the color data received from the camera
        /// </summary>
        private byte[] colorPixels;

        //---DEPTH DATA STRUCTURES

        /// <summary>
        /// Bitmap that will hold color information
        /// </summary>
        private WriteableBitmap depthColorBitmap;
        /// <summary>
        /// Intermediate storage for the depth data received from the camera
        /// </summary>
        private DepthImagePixel[] depthPixels;
        /// <summary>
        /// Intermediate storage for the depth data converted to color
        /// </summary>
        private byte[] depthColorPixels;
        /// <summary>
        /// Intermediate storage for the depth data converted to int
        /// </summary>
        private int[] depthInMm;
        //---SKELETON DATA STRUCTURES
        /// <summary>
        /// real world x-coordinate of joints
        /// </summary>
        private float[] xCoord;
        /// <summary>
        /// real world y-coordinate of joints
        /// </summary>
        private float[] yCoord;
        /// <summary>
        /// real world z-coordinate of joints
        /// </summary>
        private float[] zCoord;
        /// <summary>
        ///  Joint Type
        /// </summary>
        private JointType[] jType;
        /// <summary>
        /// 
        /// </summary>
        private DrawingGroup drawingGroup;
        /// <summary>
        /// 
        /// </summary>
        private DrawingImage imageSource;
        /// <summary>
        /// Width of output drawing
        /// </summary>
        private const float RenderWidth = 640.0f;
        /// <summary>
        /// Height of output drawing
        /// </summary>
        private const float RenderHeight = 480.0f;
        /// <summary>
        /// Brush for center point 
        /// </summary>
        private readonly Brush centerPointBrush = Brushes.Blue;
        /// <summary>
        /// Thickness of bosy center
        /// </summary>
        private const double BodyCenterThickness = 10;
        /// <summary>
        /// 
        /// </summary>
        private const double ClipBoundsThickness = 10;
        /// <summary>
        /// 
        /// </summary>
        private readonly Brush trackedJointBrush = new SolidColorBrush(Color.FromArgb(255, 68, 192, 68));
        /// <summary>
        /// 
        /// </summary>
        private readonly Brush inferredJointBrush = Brushes.Yellow;
        /// <summary>
        /// 
        /// </summary>
        private const double JointThickness = 3;
        /// <summary>
        /// 
        /// </summary>
        private readonly Pen trackedBonePen = new Pen(Brushes.Green, 6);
        /// <summary>
        /// 
        /// </summary>
        private readonly Pen inferredBonePen = new Pen(Brushes.Gray, 1);
        

        public MainWindow()
        {
            InitializeComponent();
        }      

        //---HELPER FUNCTIONS

        private static void RenderClippedEdges(Skeleton skeleton, DrawingContext drawingContext)
        {
            if (skeleton.ClippedEdges.HasFlag(FrameEdges.Bottom))
            {
                drawingContext.DrawRectangle(
                    Brushes.Red,
                    null,
                    new Rect(0, RenderHeight - ClipBoundsThickness, RenderWidth, ClipBoundsThickness));
            }

            if (skeleton.ClippedEdges.HasFlag(FrameEdges.Top))
            {
                drawingContext.DrawRectangle(
                    Brushes.Red,
                    null,
                    new Rect(0, 0, RenderWidth, ClipBoundsThickness));
            }

            if (skeleton.ClippedEdges.HasFlag(FrameEdges.Left))
            {
                drawingContext.DrawRectangle(
                    Brushes.Red,
                    null,
                    new Rect(0, 0, ClipBoundsThickness, RenderHeight));
            }

            if (skeleton.ClippedEdges.HasFlag(FrameEdges.Right))
            {
                drawingContext.DrawRectangle(
                    Brushes.Red,
                    null,
                    new Rect(RenderWidth - ClipBoundsThickness, 0, ClipBoundsThickness, RenderHeight));
            }
        }

        private Point SkeletonPointToScreen(SkeletonPoint skelpoint)
        {
            // Convert point to depth space.  
            // We are not using depth directly, but we do want the points in our 640x480 output resolution.
            DepthImagePoint depthPoint = this.sensor.CoordinateMapper.MapSkeletonPointToDepthPoint(skelpoint, DepthImageFormat.Resolution640x480Fps30);
            ColorImagePoint colorPoint = this.sensor.CoordinateMapper.MapSkeletonPointToColorPoint(skelpoint, ColorImageFormat.RgbResolution640x480Fps30);
            return new Point(depthPoint.X, depthPoint.Y);
        }

        private void DrawBone(Skeleton skeleton, DrawingContext drawingContext, JointType jointType0, JointType jointType1)
        {
            Joint joint0 = skeleton.Joints[jointType0];
            Joint joint1 = skeleton.Joints[jointType1];

            // If we can't find either of these joints, exit
            if (joint0.TrackingState == JointTrackingState.NotTracked ||
                joint1.TrackingState == JointTrackingState.NotTracked)
            {
                return;
            }

            // Don't draw if both points are inferred
            if (joint0.TrackingState == JointTrackingState.Inferred &&
                joint1.TrackingState == JointTrackingState.Inferred)
            {
                return;
            }

            // We assume all drawn bones are inferred unless BOTH joints are tracked
            Pen drawPen = this.inferredBonePen;
            if (joint0.TrackingState == JointTrackingState.Tracked && joint1.TrackingState == JointTrackingState.Tracked)
            {
                drawPen = this.trackedBonePen;
            }

            drawingContext.DrawLine(drawPen, this.SkeletonPointToScreen(joint0.Position), this.SkeletonPointToScreen(joint1.Position));
        }

        private void DrawBonesAndJoints(Skeleton skeleton, DrawingContext drawingContext)
        {
            // Render Torso
            this.DrawBone(skeleton, drawingContext, JointType.Head, JointType.ShoulderCenter);
            this.DrawBone(skeleton, drawingContext, JointType.ShoulderCenter, JointType.ShoulderLeft);
            this.DrawBone(skeleton, drawingContext, JointType.ShoulderCenter, JointType.ShoulderRight);
            this.DrawBone(skeleton, drawingContext, JointType.ShoulderCenter, JointType.Spine);
            this.DrawBone(skeleton, drawingContext, JointType.Spine, JointType.HipCenter);
            this.DrawBone(skeleton, drawingContext, JointType.HipCenter, JointType.HipLeft);
            this.DrawBone(skeleton, drawingContext, JointType.HipCenter, JointType.HipRight);

            // Left Arm
            this.DrawBone(skeleton, drawingContext, JointType.ShoulderLeft, JointType.ElbowLeft);
            this.DrawBone(skeleton, drawingContext, JointType.ElbowLeft, JointType.WristLeft);
            this.DrawBone(skeleton, drawingContext, JointType.WristLeft, JointType.HandLeft);

            // Right Arm
            this.DrawBone(skeleton, drawingContext, JointType.ShoulderRight, JointType.ElbowRight);
            this.DrawBone(skeleton, drawingContext, JointType.ElbowRight, JointType.WristRight);
            this.DrawBone(skeleton, drawingContext, JointType.WristRight, JointType.HandRight);

            // Left Leg
            this.DrawBone(skeleton, drawingContext, JointType.HipLeft, JointType.KneeLeft);
            this.DrawBone(skeleton, drawingContext, JointType.KneeLeft, JointType.AnkleLeft);
            this.DrawBone(skeleton, drawingContext, JointType.AnkleLeft, JointType.FootLeft);

            // Right Leg
            this.DrawBone(skeleton, drawingContext, JointType.HipRight, JointType.KneeRight);
            this.DrawBone(skeleton, drawingContext, JointType.KneeRight, JointType.AnkleRight);
            this.DrawBone(skeleton, drawingContext, JointType.AnkleRight, JointType.FootRight);

            // Render Joints
            foreach (Joint joint in skeleton.Joints)
            {
                Brush drawBrush = null;

                if (joint.TrackingState == JointTrackingState.Tracked)
                {
                    drawBrush = this.trackedJointBrush;
                }
                else if (joint.TrackingState == JointTrackingState.Inferred)
                {
                    drawBrush = this.inferredJointBrush;
                }

                if (drawBrush != null)
                {
                    drawingContext.DrawEllipse(drawBrush, null, this.SkeletonPointToScreen(joint.Position), JointThickness, JointThickness);
                }
            }
        }

        private void saveToFile(Skeleton[] skeletons, int ct)
        {
            //---Deal with Color
            // Encoder from bmp to png color
            BitmapEncoder cEncoder = new PngBitmapEncoder();

            // create frame from the writable bitmap and add to encoder
            cEncoder.Frames.Add(BitmapFrame.Create(this.colorBitmap));
            string path = colorFolder + i + ".png";
            // write the new file to disk
            try
            {
                using (FileStream fs = new FileStream(path, FileMode.Create))
                {
                    cEncoder.Save(fs);
                }
                this.lblStatus.Content = "Status: Save Success";
            }
            catch (IOException)
            {
                this.lblStatus.Content = "Status: Save failed";
            }

            //---Deal with Depth
            // Encoder from bmp to png depth
            BitmapEncoder dEncoder = new PngBitmapEncoder();
            dEncoder.Frames.Add(BitmapFrame.Create(this.depthColorBitmap));
            path = depthFolder + i + ".png";
            // write the new file to disk
            try
            {
                using (FileStream fs = new FileStream(path, FileMode.Create))
                {
                    dEncoder.Save(fs);
                }
                this.lblStatus.Content = "Status: Save Success";
            }
            catch (IOException)
            {
                this.lblStatus.Content = "Status: Save failed";
            }


            // Encoder from bmp to png depth
            BitmapEncoder dInMmEncoder = new PngBitmapEncoder();
            dInMmEncoder.Frames.Add(BitmapFrame.Create(this.depthColorBitmap));
            path = depthFolder +"InMm" +  i + ".png";
            // write the new file to disk
            try
            {
                using (FileStream fs = new FileStream(path, FileMode.Create))
                {
                    dInMmEncoder.Save(fs);
                }
                this.lblStatus.Content = "Status: Save Success";
            }
            catch (IOException)
            {
                this.lblStatus.Content = "Status: Save failed";
            }

           
            //Text Files
            using (StreamWriter sw = new StreamWriter(colorPath, true))
            {
                for (int c = 0; c < 307200*4 ; c++)
                {
                    if ((c + 1) % 4 != 0)
                    {
                        sw.Write(this.colorPixels[c]);
                        sw.Write(" ");
                    }
                }
                sw.Write("\n");
            }

            using (StreamWriter sw = new StreamWriter(depthPath, true))
            {
                for (int c = 0; c < 307200 ; c++)
                {
                    sw.Write(this.depthColorPixels[c]);
                    sw.Write(" ");
                }
                sw.Write("\n");
            }

            using (StreamWriter sw = new StreamWriter(depthPathInMm, true))
            {
                for (int c = 0; c < 307200; c++)
                {
                    sw.Write(this.depthInMm[c]);
                    sw.Write(" ");
                }
                sw.Write("\n");
            }

            //---Deal with Skeleton
            //Save data for skeletons available
            //Save joint coordiantes to file
            for (int q = 0; q < 6; q++)
            {
                if (skeletons[q].TrackingState == SkeletonTrackingState.Tracked)
                {
                    Skeleton skel = skeletons[q];
                    int count = 0;
                    foreach (Joint joint in skel.Joints)
                    {
                        if (joint.TrackingState == JointTrackingState.Tracked || joint.TrackingState == JointTrackingState.Inferred)
                        {
                            this.xCoord[count] = joint.Position.X;
                            this.yCoord[count] = joint.Position.Y;
                            this.zCoord[count] = joint.Position.Z;
                            this.jType[count] = joint.JointType;
                        }
                        count++;
                    }
                    // write data to text file (x-y-z-no.of tracked skeletons)
                    using (StreamWriter sw = new StreamWriter(skeletonPath, true))
                    {
                        for (int c = 0; c < countJ; c++)
                        {
                            sw.Write(this.xCoord[c]);
                            sw.Write(" ");
                            sw.Write(this.yCoord[c]);
                            sw.Write(" ");
                            sw.Write(this.zCoord[c]);
                            sw.Write(" ");
                            sw.Write(this.jType[c]);
                            sw.Write(" ");
                        }
                        sw.Write(ct);
                        sw.Write("\n");
                    }
                }
            }
        }

        //---EVENT HANDLERS

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            //Check if Kinect available
            //Ennumerate Kinect sensors
            foreach (KinectSensor potentialSensor in KinectSensor.KinectSensors)
            {
                if (potentialSensor.Status == KinectStatus.Connected)
                {
                    this.sensor = potentialSensor;
                    break;
                }
            }
            //check if kinect is available
            if (this.sensor == null)
                this.lblStatus.Content = "Status: Kinect not connected. Check connection and retry!";
            else
            {
                //---Enable data streaming
                this.sensor.ColorStream.Enable(ColorImageFormat.RgbResolution640x480Fps30);
                this.sensor.DepthStream.Enable(DepthImageFormat.Resolution640x480Fps30);
                this.sensor.SkeletonStream.Enable();
           
                //---Allocate memory for depth, color, skeleton information
                //---COLOR
                // Allocate space to put the pixels we'll receive
                this.colorPixels = new byte[this.sensor.ColorStream.FramePixelDataLength];
                // This is the bitmap we'll display on-screen
                this.colorBitmap = new WriteableBitmap(this.sensor.ColorStream.FrameWidth, this.sensor.ColorStream.FrameHeight, 96.0, 96.0, PixelFormats.Bgr32, null);
                // Set the image we display to point to the bitmap where we'll put the image data
                this.imgKinectColor.Source = this.colorBitmap;

                //---DEPTH
                // Allocate space to put the depth pixels we'll receive
                this.depthPixels = new DepthImagePixel[this.sensor.DepthStream.FramePixelDataLength];
                this.depthInMm = new int[this.sensor.DepthStream.FramePixelDataLength];
                // Allocate space to put the color pixels we'll create
                this.depthColorPixels = new byte[this.sensor.DepthStream.FramePixelDataLength * sizeof(int)];
                // This is the bitmap we'll display on-screen
                this.depthColorBitmap = new WriteableBitmap(this.sensor.DepthStream.FrameWidth, this.sensor.DepthStream.FrameHeight, 96.0, 96.0, PixelFormats.Bgr32, null);
                // Set the image we display to point to the bitmap where we'll put the image data
                this.imgKinectDepth.Source = this.depthColorBitmap;
                
                //---SKELETON
                // Create the drawing group we'll use for drawing
                this.drawingGroup = new DrawingGroup();
                // Create an image source that we can use in our image control
                this.imageSource = new DrawingImage(this.drawingGroup);
                // Set the image we display to point to the bitmap where we'll put the image data
                this.imgKinectSkeleton.Source = this.imageSource;
                //Save memory space for joint information 
                this.xCoord = new float[20];
                this.yCoord = new float[20];
                this.zCoord = new float[20];
                this.jType = new JointType[20];

                //---Start the kinect                
                this.sensor.Start();
                float tempAngle = 0;
                tempAngle = this.sensor.ElevationAngle;
                lblKinectElevation.Content = tempAngle;
                //---Register an event that fires when all data is ready frames data is ready
                //this.sensor.ColorFrameReady += this.SensorColorFrameReady;
                //this.sensor.DepthFrameReady += this.SensorDepthFrameReady;
                //this.sensor.SkeletonFrameReady += this.SensorSkeletonFrameReady;
                do
                {
                    this.sensor.AllFramesReady += this.sensor_AllFramesReady;
                }while (done == true);
            }
        }

        private void sensor_AllFramesReady(object sender, AllFramesReadyEventArgs e)
        {
            done = false;
            Skeleton[] skeletons = new Skeleton[0];
            using (ColorImageFrame colorFrame = e.OpenColorImageFrame())
            {
                using (DepthImageFrame depthFrame = e.OpenDepthImageFrame())
                {
                    using (SkeletonFrame skeletonFrame = e.OpenSkeletonFrame())
                    {
                        using (DrawingContext dc = this.drawingGroup.Open())
                        {
                            if (colorFrame != null && depthFrame != null && skeletonFrame != null)
                            {
                                //count to make sure the skeleton frame contains at least one tracked skeleton
                                skeletons = new Skeleton[skeletonFrame.SkeletonArrayLength];
                                skeletonFrame.CopySkeletonDataTo(skeletons);
                                int countS = 0;
                                for (int q = 0; q < 6;q++)
                                {
                                    if (skeletons[q].TrackingState == SkeletonTrackingState.Tracked)
                                    {
                                        this.lblS.Content = q;
                                        countS++;
                                    }
                                }
                                this.lblC.Content = countS;
                         
                                //---Deal with color data
                                // Copy the pixel data from the image to a temporary array
                                colorFrame.CopyPixelDataTo(this.colorPixels);
                                // Write the pixel data into our bitmap
                                this.colorBitmap.WritePixels(new Int32Rect(0, 0, this.colorBitmap.PixelWidth, this.colorBitmap.PixelHeight), this.colorPixels, this.colorBitmap.PixelWidth * sizeof(int), 0);

                                //---Deal with depth data
                                // Copy the pixel data from the image to a temporary array
                                depthFrame.CopyDepthImagePixelDataTo(this.depthPixels);
                                for (int i = 0; i < 307200; i++)
                                    depthInMm[i] = depthPixels[i].Depth;
                                // Get the min and max reliable depth for the current frame
                                int minDepth = depthFrame.MinDepth;
                                int maxDepth = depthFrame.MaxDepth;
                                // Convert the depth to RGB
                                int colorPixelIndex = 0;
                                for (int i = 0; i < this.depthPixels.Length; ++i)
                                {
                                    // Get the depth for this pixel
                                    short depth = depthPixels[i].Depth;

                                    // To convert to a byte, we're discarding the most-significant
                                    // rather than least-significant bits.
                                    // We're preserving detail, although the intensity will "wrap."
                                    // Values outside the reliable depth range are mapped to 0 (black).

                                    // Note: Using conditionals in this loop could degrade performance.
                                    // Consider using a lookup table instead when writing production code.
                                    // See the KinectDepthViewer class used by the KinectExplorer sample
                                    // for a lookup table example.
                                    byte intensity = (byte)(depth >= minDepth && depth <= maxDepth ? depth : 0);
                                    // Write out blue byte
                                    this.depthColorPixels[colorPixelIndex++] = intensity;
                                    // Write out green byte
                                    this.depthColorPixels[colorPixelIndex++] = intensity;
                                    // Write out red byte                        
                                    this.depthColorPixels[colorPixelIndex++] = intensity;
                                    // We're outputting BGR, the last byte in the 32 bits is unused so skip it
                                    // If we were outputting BGRA, we would write alpha here.
                                    ++colorPixelIndex;
                                }
                                // Write the pixel data into our bitmap
                                this.depthColorBitmap.WritePixels(new Int32Rect(0, 0, this.depthColorBitmap.PixelWidth, this.depthColorBitmap.PixelHeight), this.depthColorPixels, this.depthColorBitmap.PixelWidth * sizeof(int), 0);

                                //---Deal with skeleton data

                                // Draw a transparent background to set the render size
                                dc.DrawRectangle(Brushes.Black, null, new Rect(0.0, 0.0, RenderWidth, RenderHeight));
                                if (skeletons.Length != 0)
                                {
                                    //Render all skeletons
                                    foreach (Skeleton skel in skeletons)
                                    {
                                        RenderClippedEdges(skel, dc);

                                        if (skel.TrackingState == SkeletonTrackingState.Tracked)
                                        {
                                            //Draw to skeleton on screen
                                            this.DrawBonesAndJoints(skel, dc);
                                        }
                                        else if (skel.TrackingState == SkeletonTrackingState.PositionOnly)
                                        {
                                            dc.DrawEllipse(this.centerPointBrush, null, this.SkeletonPointToScreen(skel.Position), BodyCenterThickness, BodyCenterThickness);
                                        }
                                    }
                                }
                                
                                // prevent drawing outside of our render area
                                this.drawingGroup.ClipGeometry = new RectangleGeometry(new Rect(0.0, 0.0, RenderWidth, RenderHeight));

                                //--- Save data to file/disk
                                if (colorFrame != null && depthFrame != null && skeletonFrame != null && countS>0)
                                {
                                    if (this.flagCapture == true)
                                    {
                                        this.saveToFile(skeletons, countS);
                                    }
                                    i++;
                                }
                            }
                        }
                    }
                }
            }
            done = true;
        }
          
        private void sliderKinectElevation_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            lblKinectElevation.Content = (int) sliderKinectElevation.Value;
        }

        private void btnKinectAdjust_Click(object sender, RoutedEventArgs e)
        {
            this.sensor.ElevationAngle = (int)sliderKinectElevation.Value;
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            this.sensor.Stop();
        }
  
    }
}
