package sandy.events
{
    import sandy.core.face.Polygon;
    import sandy.core.Object3D;
    
    public static const OBJECT_CLICK:uint = 0;
    public static const OBJECT_DOUBLE_CLICK:uint = 1;
    public static const OBJECT_MOUSE_UP:uint = 2;
    public static const OBJECT_MOUSE_OUT:uint = 3;
    public static const OBJECT_MOUSE_DOWN:uint = 4;
    public static const OBJECT_MOUSE_MOVE:uint = 5;
    public static const OBJECT_MOUSE_WHEEL:uint = 6;
    public static const OBJECT_ROLL_OUT:uint = 7;
    public static const OBJECT_ROLL_OVER:uint = 8;
    public static const OBJECT_MOUSE_WHEEL:uint = 9;
    
    public static const FACE_CLICK:uint = 10;
    public static const FACE_DOUBLE_CLICK:uint = 11;
    public static const FACE_MOUSE_UP:uint = 12;
    public static const FACE_MOUSE_OUT:uint = 13;
    public static const FACE_MOUSE_DOWN:uint = 14;
    public static const FACE_MOUSE_MOVE:uint = 15;
    public static const FACE_MOUSE_WHEEL:uint = 16;
    public static const FACE_ROLL_OUT:uint = 17;
    public static const FACE_ROLL_OVER:uint = 18;
    public static const FACE_MOUSE_WHEEL:uint = 19;
        
    public class InteractionEvent
    {
        public var m_uType:uint;
        public var m_oObject:Object3D;
        public var m_oFace:Polygon;
         
        public function InteractionEvent( p_uType:uint, p_oObject:Object3D, p_oFace:Polygon = null )
        {
            m_uType = p_uType;
            m_oFace = p_oFace;
            m_oObject = p_oObject;
        }
        
        override public function toString():String
        {
            return new String( getQualifiedClassName(this) + " object reference : "+m_oObject+", polygon face reference :"+m_oFace ) ;
        }
    }
}